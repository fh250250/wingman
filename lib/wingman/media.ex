defmodule Wingman.Media do
  @moduledoc """
  媒体库
  """

  import Ecto.Query, warn: false

  alias Wingman.Repo
  alias Wingman.Media.Folder
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
end
