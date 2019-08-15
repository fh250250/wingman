defmodule Wingman.Storage do
  @moduledoc """
  存储库
  """

  @storage_config Application.get_env(:wingman, Wingman.Storage)

  import Ecto.Query, warn: false

  alias Wingman.Repo
  alias Wingman.Storage.{Folder, Upload, Chunk}
  alias Wingman.Storage.File, as: StorageFile

  @doc """
  通过 id 获取目录，没有参数则返回根目录
  """
  @spec get_folder() :: nil | Folder.t
  @spec get_folder(id :: String.t | integer) :: nil | Folder.t
  def get_folder() do
    query =
      from f in Folder,
      where: is_nil(f.parent_id)

    Repo.one(query)
  end
  def get_folder(id), do: Repo.get(Folder, id)

  @doc """
  列出文件与目录
  """
  @spec ls(folder :: Folder.t) :: %{folders: list(Folder.t), files: list(StorageFile.t)}
  def ls(%Folder{} = folder) do
    case Repo.preload(folder, [:folders, :files]) do
      %Folder{folders: folders, files: files} ->
        %{folders: folders, files: files}
      nil ->
        %{folders: [], files: []}
    end
  end

  @doc """
  创建目录
  """
  @spec mkdir(folder :: Folder.t, name :: String.t) :: {:ok, Folder.t} | {:error, Ecto.Changeset.t | term}
  def mkdir(%Folder{} = folder, name) do
    update_lft_query = from f in Folder, where: f.lft > ^folder.rht
    update_rht_query = from f in Folder, where: f.rht >= ^folder.rht
    create_changeset =
      folder
      |> Ecto.build_assoc(:folders)
      |> Folder.changeset(%{name: name, lft: folder.rht, rht: folder.rht + 1})

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:update_lft, update_lft_query, inc: [lft: 2])
    |> Ecto.Multi.update_all(:update_rht, update_rht_query, inc: [rht: 2])
    |> Ecto.Multi.insert(:create, create_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: new_folder}} -> {:ok, new_folder}
      {:error, :create, changeset, _} -> {:error, changeset}
      {:error, _, _, _} -> {:error, "创建目录失败"}
    end
  end

  @doc """
  保存上传的文件
  """
  @spec save_file(String.t, Plug.Upload.t) :: :ok | {:error, term}
  def save_file(path, %Plug.Upload{filename: filename, path: filepath}) do
    with {:ok, dir} <- safe_path(path),
         {:ok, destpath} <- build_destpath(dir, filename)
    do
      File.rename(filepath, destpath)
    end
  end

  # 根据目录与文件名构造路径
  defp build_destpath(dir, filename) do
    with {:ok, path} <- Path.join(dir, filename) |> safe_path() do
      destpath =
        if File.exists?(path) do
          Path.rootname(path) <> "_" <> random_string(8) <> Path.extname(path)
        else
          path
        end

      {:ok, destpath}
    end
  end

  @doc """
  移动或重命名文件与目录
  """
  @spec rename(String.t, String.t) :: :ok | {:error, term}
  def rename(source, dest) do
    with {:ok, sourcepath} <- safe_path(source),
         {:ok, destpath} <- safe_path(dest)
    do
      File.rename(sourcepath, destpath)
    end
  end

  @doc """
  删除目录
  """
  @spec rmdir(String.t) :: :ok | {:error, term}
  def rmdir(path) do
    with {:ok, dir} <- safe_path(path) do
      relative_dir = Path.relative_to(dir, @storage_config[:root_path])

      query =
        from u in Upload,
          where: u.dir == ^relative_dir

      if Repo.exists?(query) do
        {:error, "有上传任务，无法删除"}
      else
        File.rmdir(dir)
      end
    end
  end

  @doc """
  删除文件
  """
  @spec rm(String.t) :: :ok | {:error, term}
  def rm(path) do
    with {:ok, sp} <- safe_path(path) do
      File.rm(sp)
    end
  end

  @doc """
  获取或者创建一个上传任务
  """
  @spec get_or_create_upload(map) :: {:ok, {Upload.t, list}} | {:error, Ecto.Changeset.t | term}
  def get_or_create_upload(%{"dir" => dir, "md5" => md5} = attrs) do
    with {:ok, safe_dir} <- safe_path(dir) do
      relative_dir = Path.relative_to(safe_dir, @storage_config[:root_path])

      query =
        from u in Upload,
          where: u.dir == ^relative_dir and u.md5 == ^md5

      case Repo.one(query) do
        nil -> create_upload(%{attrs | "dir" => relative_dir})
        upload -> {:ok, get_upload_status(upload)}
      end
    end
  end

  defp create_upload(attrs) do
    %Upload{}
    |> Upload.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, upload} -> {:ok, get_upload_status(upload)}
      error -> error
    end
  end

  defp get_upload_status(%Upload{} = upload) do
    chunk_count = ceil(upload.size / upload.chunk_size)
    loaded_numbers =
      upload
      |> Ecto.assoc(:chunks)
      |> select([c], c.number)
      |> Repo.all()

    chunks =
      1..chunk_count
      |> Enum.map(fn number ->
        if number in loaded_numbers do
          %{number: number, loaded: true}
        else
          size =
            if number == chunk_count do
              upload.size - (number - 1) * upload.chunk_size
            else
              upload.chunk_size
            end

          %{number: number,
            loaded: false,
            offset: (number - 1) * upload.chunk_size,
            size: size}
        end
      end)

    {upload, chunks}
  end

  @doc """
  保存分块
  """
  @spec save_chunk(map, Plug.Upload.t) :: {:ok, Chunk.t} | {:error, Ecto.Changeset.t | term}
  def save_chunk(%{number: number, upload_id: upload_id}, %Plug.Upload{path: filepath}) do
    path = random_string(32) <> ".part"
    destpath = Path.join([@storage_config[:tmp_path], path])
    changeset = Chunk.changeset(%Chunk{}, %{number: number, path: path, upload_id: upload_id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create_chunk, changeset)
    |> Ecto.Multi.update_all(:touch_upload, where(Upload, id: ^upload_id), set: [updated_at: NaiveDateTime.utc_now()])
    |> Ecto.Multi.run(:write_chunk, fn _repo, _changes ->
      with :ok <- File.rename(filepath, destpath) do
        {:ok, nil}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_chunk: chunk}} -> {:ok, chunk}
      {:error, :create_chunk, changeset, _} -> {:error, changeset}
      {:error, _, reason, _} -> {:error, reason}
    end
  end

  @doc """
  合并分块
  """
  @spec combine_chunks(term) :: :ok | {:error, term}
  def combine_chunks(upload_id) do
    with upload when not is_nil(upload) <- Repo.get(Upload, upload_id) |> Repo.preload(:chunks),
         chunk_count <- ceil(upload.size / upload.chunk_size),
         true <- length(upload.chunks) == chunk_count
    do
      do_combine_chunks(upload)
    else
      _ -> {:error, "分块不全, 无法合并"}
    end
  end

  defp do_combine_chunks(%Upload{} = upload) do
    combine_filepath = Path.join([@storage_config[:tmp_path], random_string(32)])

    # 合并成一个大文件
    upload.chunks
    |> Enum.sort_by(&(&1.number))
    |> Enum.map(&File.stream!(Path.join([@storage_config[:tmp_path], &1.path]), [], 8 * 1024))
    |> Stream.concat()
    |> Stream.into(File.stream!(combine_filepath, [:write], 8 * 1024))
    |> Stream.run()

    delete_upload!(upload)

    # 保存大文件，这里直接构造一个 Plug.Upload 来复用逻辑
    save_file(upload.dir, %Plug.Upload{filename: upload.filename, path: combine_filepath})
  end

  @doc """
  删除上传任务及分块和文件
  """
  def delete_upload!(%Upload{} = upload) do
    # 删除所有分块文件
    Enum.each(upload.chunks, &File.rm(Path.join([@storage_config[:tmp_path], &1.path])))

    # 删除上传任务及所有分块，有外键约束的级联删除，这里只删除上传任务即可
    Repo.delete!(upload)
  end




  # 确保路径被限制在存储目录中
  defp safe_path(path) do
    abs_path = Path.expand(path, @storage_config[:root_path])

    if String.starts_with?(abs_path, @storage_config[:root_path]) do
      {:ok, abs_path}
    else
      {:error, "非法路径"}
    end
  end

  defp random_string(length) when length > 0 do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end
end
