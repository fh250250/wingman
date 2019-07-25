defmodule Wingman.Media do
  @moduledoc """
  媒体库
  """

  import Ecto.Query, warn: false

  alias Wingman.Repo
  alias Wingman.Media.{Folder, Upload, UploadChunk}
  alias Wingman.Media.File, as: MediaFile

  @media_config Application.get_env(:wingman, Wingman.Media)

  @doc """
  通过 id 获取目录，没有参数则返回根目录
  """
  def get_folder() do
    query =
      from f in Folder,
      where: is_nil(f.parent_id)

    Repo.one(query)
  end
  def get_folder(id), do: Repo.get(Folder, id)

  @doc """
  创建目录
  """
  def create_folder(%Folder{} = folder, attrs) do
    folder
    |> Ecto.build_assoc(:folders)
    |> Folder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  列出目录
  """
  def list_folder(%Folder{} = folder) do
    folder
    |> Repo.preload([:folders, :files])
  end




  @doc """
  上传文件的访问路径
  """
  def public_path(%MediaFile{path: path}), do: Path.join([@media_config[:public_path], path])

  @doc """
  保存文件
  """
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

    destpath = Path.join([@media_config[:upload_path], path])

    size =
      case File.stat(filepath) do
        {:ok, %File.Stat{} = stat} -> stat.size
        {:error, _reason} -> 0
      end

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create_file,
      folder
      |> Ecto.build_assoc(:files)
      |> MediaFile.changeset(%{name: name, size: size, content_type: content_type, path: path}))
    |> Ecto.Multi.run(:write_file, fn _repo, _changes ->
      with :ok <- Path.dirname(destpath) |> File.mkdir_p(),
           :ok <- File.rename(filepath, destpath)
      do
        {:ok, nil}
      else
        _ -> {:error, "写入文件失败"}
      end
    end)
    |> Repo.transaction()
  end

  defp random_string(length) when length > 0 do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end




  @doc """
  获取或者创建一个上传任务
  """
  def get_or_create_upload(%Folder{} = folder, %{"md5" => md5} = attrs) do
    folder
    |> Ecto.assoc(:uploads)
    |> where(md5: ^md5)
    |> Repo.one()
    |> case do
      nil -> create_upload(folder, attrs)
      upload -> {:ok, get_upload_status(upload)}
    end
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

    %{upload: upload, chunks: chunks}
  end




  @doc """
  保存分块
  """
  def save_chunk(%{number: number, upload_id: upload_id}, %Plug.Upload{path: filepath}) do
    path = random_string(32)
    destpath = Path.join([@media_config[:chunk_path], path])
    changeset = UploadChunk.changeset(%UploadChunk{}, %{number: number, path: path, upload_id: upload_id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create_chunk, changeset)
    |> Ecto.Multi.update_all(:touch_upload, where(Upload, id: ^upload_id), set: [updated_at: NaiveDateTime.utc_now()])
    |> Ecto.Multi.run(:write_chunk, fn _repo, _changes ->
      with :ok <- Path.dirname(destpath) |> File.mkdir_p(),
           :ok <- File.rename(filepath, destpath)
      do
        {:ok, nil}
      else
        _ -> {:error, "写入分块失败"}
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  合并分块
  """
  def combine_chunks(upload_id) do
    with upload when not is_nil(upload) <- Upload |> Repo.get(upload_id) |> Repo.preload([:chunks, :folder]),
         chunk_count <- ceil(upload.size / upload.chunk_size),
         true <- length(upload.chunks) == chunk_count
    do
      do_combine_chunks(upload)
    else
      _ -> {:error, "分块不全, 无法合并"}
    end
  end

  defp do_combine_chunks(%Upload{} = upload) do
    combine_filepath = Path.join([@media_config[:chunk_path], random_string(32)])

    # 合并成一个大文件
    upload.chunks
    |> Enum.sort_by(&(&1.number))
    |> Enum.map(&File.stream!(Path.join([@media_config[:chunk_path], &1.path]), [], 8 * 1024))
    |> Stream.concat()
    |> Stream.into(File.stream!(combine_filepath, [:write], 8 * 1024))
    |> Stream.run()

    delete_upload(upload)

    # 保存大文件，这里直接构造一个 Plug.Upload 来复用逻辑
    upload.folder
    |> save_file(%Plug.Upload{filename: upload.filename, content_type: MIME.from_path(upload.filename), path: combine_filepath})
    |> case do
      {:ok, %{create_file: new_file}} -> {:ok, new_file}
      {:error, :create_file, changeset, _} -> {:error, changeset}
      {:error, _, reason, _} -> {:error, reason}
    end
  end

  @doc """
  删除上传任务及分块和文件
  """
  def delete_upload(%Upload{} = upload) do
    # 删除所有分块文件
    Enum.each(upload.chunks, &File.rm(Path.join([@media_config[:chunk_path], &1.path])))

    # 删除上传任务及所有分块，有外键约束，这里只删除上传任务即可
    Repo.delete!(upload)
  end
end
