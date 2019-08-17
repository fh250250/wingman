defmodule Wingman.Storage do
  @moduledoc """
  存储库
  """

  @storage_config Application.get_env(:wingman, Wingman.Storage)
  @chunk_size 4 * 1024 * 1024

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
  @spec mkdir(folder :: Folder.t, name :: String.t) :: :ok | {:error, Ecto.Changeset.t | String.t}
  def mkdir(%Folder{} = folder, name) do
    update_lft_query = from f in Folder, where: f.lft > ^folder.rgt
    update_rgt_query = from f in Folder, where: f.rgt >= ^folder.rgt
    create_changeset =
      folder
      |> Ecto.build_assoc(:folders)
      |> Folder.changeset(%{name: name, lft: folder.rgt, rgt: folder.rgt + 1})

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:update_lft, update_lft_query, inc: [lft: 2])
    |> Ecto.Multi.update_all(:update_rgt, update_rgt_query, inc: [rgt: 2])
    |> Ecto.Multi.insert(:create, create_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> :ok
      {:error, :create, changeset, _} -> {:error, changeset}
      {:error, _, _, _} -> {:error, "创建目录失败"}
    end
  end

  @doc """
  移动目录或文件
  """
  @spec mv(folder_or_file :: Folder.t | StorageFile.t, dest_folder :: Folder.t) :: :ok | {:error, Ecto.Changeset.t | String.t}
  def mv(%Folder{} = folder, %Folder{} = dest_folder) do
    with false <- is_root_folder?(folder),
         false <- folder.id == dest_folder.id,
         false <- is_child_folder?(dest_folder, folder),
         false <- folder.parent_id == dest_folder.id
    do
      folder_size = folder.rgt - folder.lft + 1

      Repo.transaction(fn ->
        # 1. 移除需要移动的目录，这里把左右值设成负数
        from(f in Folder,
          where: f.lft >= ^folder.lft and f.rgt <= ^folder.rgt,
          update: [set: [lft: 0 - f.lft, rgt: 0 - f.rgt]])
        |> Repo.update_all([])

        # 2. 调整左右值来收缩空间
        from(f in Folder,
          where: f.lft > ^folder.rgt,
          update: [inc: [lft: ^-folder_size]])
        |> Repo.update_all([])

        from(f in Folder,
          where: f.rgt > ^folder.rgt,
          update: [inc: [rgt: ^-folder_size]])
        |> Repo.update_all([])

        # 3. 调整左右值来腾出新的位置
        dest_folder = Repo.get!(Folder, dest_folder.id)

        from(f in Folder,
          where: f.lft > ^dest_folder.rgt,
          update: [inc: [lft: ^folder_size]])
        |> Repo.update_all([])

        from(f in Folder,
          where: f.rgt >= ^dest_folder.rgt,
          update: [inc: [rgt: ^folder_size]])
        |> Repo.update_all([])

        # 4. 修改需要移动的目录的左右值
        delta = folder.lft - dest_folder.rgt

        from(f in Folder,
          where: f.lft <= ^-folder.lft and f.rgt >= ^-folder.rgt,
          update: [set: [lft: 0 - f.lft - ^delta, rgt: 0 - f.rgt - ^delta]])
        |> Repo.update_all([])

        # 5. 设置新的目录
        folder = Repo.get!(Folder, folder.id)

        folder
        |> Folder.changeset(%{parent_id: dest_folder.id})
        |> Repo.update()
        |> case do
          {:ok, _} -> nil
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)
      |> case do
        {:ok, _} -> :ok
        {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
        {:error, _} -> {:error, "移动目录失败"}
      end
    else
      _ -> {:error, "非法目录"}
    end
  end
  def mv(%StorageFile{} = file, %Folder{id: folder_id}) do
    file
    |> StorageFile.changeset(%{folder_id: folder_id})
    |> Repo.update()
    |> case do
      {:ok, _} -> :ok
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  重命名目录或文件
  """
  @spec rename(folder_or_file :: Folder.t | StorageFile.t, name :: String.t) :: :ok | {:error, Ecto.Changeset | String.t}
  def rename(%Folder{} = folder, name) do
    with false <- is_root_folder?(folder) do
      folder
      |> Folder.changeset(%{name: name})
      |> Repo.update()
      |> case do
        {:ok, _} -> :ok
        {:error, changeset} -> {:error, changeset}
      end
    else
      _ -> {:error, "非法目录"}
    end
  end
  def rename(%StorageFile{} = file, name) do
    file
    |> StorageFile.changeset(%{name: name})
    |> Repo.update()
    |> case do
      {:ok, _} -> :ok
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  删除非空目录
  """
  @spec rmdir(folder :: Folder.t) :: :ok | {:error, Ecto.Changeset | String.t}
  def rmdir(%Folder{} = folder) do
    with false <- is_root_folder?(folder) do
      folder_size = folder.rgt - folder.lft + 1
      update_lft_query = from f in Folder, where: f.lft > ^folder.rgt
      update_rgt_query = from f in Folder, where: f.rgt > ^folder.rgt

      Ecto.Multi.new()
      |> Ecto.Multi.delete(:delete, Folder.delete_changeset(folder))
      |> Ecto.Multi.update_all(:update_lft, update_lft_query, inc: [lft: -folder_size])
      |> Ecto.Multi.update_all(:update_rgt, update_rgt_query, inc: [rgt: -folder_size])
      |> Repo.transaction()
      |> case do
        {:ok, _} -> :ok
        {:error, :delete, changeset, _} -> {:error, changeset}
        {:error, _, _, _} -> {:error, "删除目录失败"}
      end
    else
      _ -> {:error, "非法目录"}
    end
  end

  @doc """
  保存文件
  """
  @spec save_file(folder :: Folder.t, upload :: Plug.Upload.t) :: :ok | {:error, Ecto.Changeset | String.t}
  def save_file(%Folder{} = folder, %Plug.Upload{filename: filename, path: filepath, content_type: content_type}) do
    name =
      Ecto.assoc(folder, :files)
      |> where(name: ^filename)
      |> Repo.exists?()
      |> case do
        true -> Path.rootname(filename) <> "_" <> random_string(8) <> Path.extname(filename)
        false -> filename
      end

    today = Date.utc_today()

    path = Path.join([
      to_string(today.year),
      to_string(today.month),
      to_string(today.day),
      random_string(32) <> Path.extname(filename)
    ])

    destpath = Path.join(@storage_config[:root_path], path)

    size =
      case File.stat(filepath) do
        {:ok, %File.Stat{} = stat} -> stat.size
        {:error, _} -> 0
      end

    create_file_changeset =
      folder
      |> Ecto.build_assoc(:files)
      |> StorageFile.changeset(%{name: name, size: size, content_type: content_type, path: path})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, create_file_changeset)
    |> Ecto.Multi.run(:write, fn _repo, _changes ->
      with :ok <- Path.dirname(destpath) |> File.mkdir_p(),
           :ok <- File.rename(filepath, destpath)
      do
        {:ok, nil}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> :ok
      {:error, :create, changeset, _} -> {:error, changeset}
      {:error, _, _, _} -> {:error, "写入文件失败"}
    end
  end

  @doc """
  通过 id 获取文件
  """
  @spec get_file(id :: String.t | integer) :: nil | StorageFile.t
  def get_file(id), do: Repo.get(StorageFile, id)

  @doc """
  删除文件
  """
  @spec rm(file :: StorageFile.t) :: :ok | {:error, Ecto.Changeset.t | String.t}
  def rm(%StorageFile{} = file) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:delete, file)
    |> Ecto.Multi.run(:remove, fn _repo, _changes ->
      Path.join(@storage_config[:root_path], file.path)
      |> File.rm()
      |> case do
        :ok -> {:ok, nil}
        {:error, reason} -> {:error, reason}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> :ok
      {:error, :delete, changeset, _} -> {:error, changeset}
      {:error, _, _, _} -> {:error, "删除文件失败"}
    end
  end

  @doc """
  获取或者创建一个上传任务
  """
  @spec get_or_create_upload(folder :: Folder.t, attrs :: map) :: {:ok, {Upload.t, list}} | {:error, Ecto.Changeset.t}
  def get_or_create_upload(%Folder{} = folder, %{md5: md5} = attrs) do
    folder
    |> Ecto.assoc(:uploads)
    |> where(md5: ^md5)
    |> Repo.one()
    |> case do
      nil -> create_upload(folder, attrs)
      upload -> {:ok, get_upload_status(upload)}
    end
  end

  @doc """
  保存分块
  """
  @spec save_chunk(attrs :: map, Plug.Upload.t) :: :ok | {:error, Ecto.Changeset.t | String.t}
  def save_chunk(%{number: number, upload_id: upload_id}, %Plug.Upload{path: filepath}) do
    path = random_string(32) <> ".part"
    destpath = Path.join(@storage_config[:tmp_path], path)
    changeset = Chunk.changeset(%Chunk{}, %{number: number, path: path, upload_id: upload_id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, changeset)
    |> Ecto.Multi.update_all(:touch, where(Upload, id: ^upload_id), set: [updated_at: NaiveDateTime.utc_now()])
    |> Ecto.Multi.run(:write, fn _repo, _changes ->
      with :ok <- Path.dirname(destpath) |> File.mkdir_p(),
           :ok <- File.rename(filepath, destpath)
      do
        {:ok, nil}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> :ok
      {:error, :create, changeset, _} -> {:error, changeset}
      {:error, _, _, _} -> {:error, "保存分块失败"}
    end
  end

  @doc """
  合并分块
  """
  @spec combine_chunks(upload_id :: String.t | integer) :: :ok | {:error, Ecto.Changeset.t | String.t}
  def combine_chunks(upload_id) do
    with upload when not is_nil(upload) <- Repo.get(Upload, upload_id) |> Repo.preload([:chunks, :folder]),
         chunk_count <- ceil(upload.size / @chunk_size),
         true <- length(upload.chunks) == chunk_count
    do
      do_combine_chunks(upload)
    else
      _ -> {:error, "分块不全, 无法合并"}
    end
  end

  @doc """
  删除上传任务及分块和文件
  """
  def delete_upload!(%Upload{} = upload) do
    # 删除所有分块文件
    Enum.each(upload.chunks, &File.rm(Path.join(@storage_config[:tmp_path], &1.path)))

    # 删除上传任务及所有分块，有外键约束的级联删除，这里只删除上传任务即可
    Repo.delete!(upload)
  end




  ########## 私有函数 ##########

  defp is_root_folder?(%Folder{parent_id: nil}), do: true
  defp is_root_folder?(%Folder{}), do: false

  defp is_child_folder?(%Folder{} = child_folder, %Folder{} = parent_folder) do
    child_folder.lft > parent_folder.lft && child_folder.rgt < parent_folder.rgt
  end

  defp random_string(length) when length > 0 do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  defp create_upload(%Folder{} = folder, attrs) do
    folder
    |> Ecto.build_assoc(:uploads)
    |> Upload.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, upload} -> {:ok, get_upload_status(upload)}
      error -> error
    end
  end

  defp get_upload_status(%Upload{} = upload) do
    chunk_count = ceil(upload.size / @chunk_size)
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
              upload.size - (number - 1) * @chunk_size
            else
              @chunk_size
            end

          %{number: number,
            loaded: false,
            offset: (number - 1) * @chunk_size,
            size: size}
        end
      end)

    {upload, chunks}
  end

  defp do_combine_chunks(%Upload{} = upload) do
    combine_filepath = Path.join(@storage_config[:tmp_path], random_string(32))

    # 合并成一个大文件
    upload.chunks
    |> Enum.sort_by(&(&1.number))
    |> Enum.map(&File.stream!(Path.join(@storage_config[:tmp_path], &1.path), [], 8 * 1024))
    |> Stream.concat()
    |> Stream.into(File.stream!(combine_filepath, [:write], 8 * 1024))
    |> Stream.run()

    delete_upload!(upload)

    # 保存大文件，这里直接构造一个 Plug.Upload 来复用逻辑
    save_file(upload.folder, %Plug.Upload{filename: upload.filename, content_type: MIME.from_path(upload.filename), path: combine_filepath})
  end
end
