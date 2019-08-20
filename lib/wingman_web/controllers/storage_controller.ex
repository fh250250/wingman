defmodule WingmanWeb.StorageController do
  use WingmanWeb, :controller

  alias Wingman.Storage
  alias Wingman.Storage.Folder

  action_fallback :fallback

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def ls(conn, %{"folder_id" => folder_id}) do
    with {:ok, folder} <- find_folder_by_id(folder_id),
         {folders, files} <- Storage.ls(folder)
    do
      render(conn, "ls.json", folders: folders, files: files)
    end
  end

  def ls_folders(conn, %{"folder_id" => folder_id}) do
    with {:ok, folder} <- find_folder_by_id(folder_id),
         folders <- Storage.ls_folders(folder)
    do
      render(conn, "ls_folders.json", folders: folders)
    end
  end

  def mkdir(conn, %{"folder_id" => folder_id, "name" => name}) do
    with {:ok, folder} <- find_folder_by_id(folder_id),
         :ok <- Storage.mkdir(folder, name)
    do
      json(conn, %{ok: true})
    end
  end

  def rmdir(conn, %{"folder_id" => folder_id}) do
    with {:ok, folder} <- find_folder_by_id(folder_id),
         :ok <- Storage.rmdir(folder)
    do
      json(conn, %{ok: true})
    end
  end

  def rename_folder(conn, %{"folder_id" => folder_id, "name" => name}) do
    with {:ok, folder} <- find_folder_by_id(folder_id),
         :ok <- Storage.rename(folder, name)
    do
      json(conn, %{ok: true})
    end
  end

  def rename_file(conn, %{"file_id" => file_id, "name" => name}) do
    with {:ok, file} <- find_file_by_id(file_id),
         :ok <- Storage.rename(file, name)
    do
      json(conn, %{ok: true})
    end
  end

  def move_folder(conn, %{"folder_id" => folder_id, "dest_folder_id" => dest_folder_id}) do
    with {:ok, folder} <- find_folder_by_id(folder_id),
         {:ok, dest_folder} <- find_folder_by_id(dest_folder_id),
         :ok <- Storage.mv(folder, dest_folder)
    do
      json(conn, %{ok: true})
    end
  end

  def move_file(conn, %{"file_id" => file_id, "dest_folder_id" => dest_folder_id}) do
    with {:ok, file} <- find_file_by_id(file_id),
         {:ok, dest_folder} <- find_folder_by_id(dest_folder_id),
         :ok <- Storage.mv(file, dest_folder)
    do
      json(conn, %{ok: true})
    end
  end

  def rm(conn, %{"file_id" => file_id}) do
    with {:ok, file} <- find_file_by_id(file_id),
         :ok <- Storage.rm(file)
    do
      json(conn, %{ok: true})
    end
  end

  def small_upload(conn, %{"file" => %Plug.Upload{} = upload_file} = params) do
    with {:ok, folder} <- find_folder_by_id(params["folder_id"]),
         :ok <- Storage.save_file(folder, upload_file)
    do
      json(conn, %{ok: true})
    end
  end

  def large_upload(conn, %{"folder_id" => folder_id, "md5" => md5, "filename" => filename, "size" => size}) do
    with {:ok, folder} <- find_folder_by_id(folder_id),
         {:ok, {upload, chunks}} <- Storage.get_or_create_upload(folder, %{md5: md5, filename: filename, size: size})
    do
      json(conn, %{upload_id: upload.id, chunks: chunks})
    end
  end

  def chunk(conn, %{"number" => number, "upload_id" => upload_id, "chunk" => %Plug.Upload{} = chunk_file}) do
    with :ok <- Storage.save_chunk(%{number: number, upload_id: upload_id}, chunk_file) do
      json(conn, %{ok: true})
    end
  end

  def combine(conn, %{"upload_id" => upload_id}) do
    with :ok <- Storage.combine_chunks(upload_id) do
      json(conn, %{ok: true})
    end
  end




  defp find_folder_by_id(nil), do: Storage.get_folder() |> wrap_find_foder_by_id()
  defp find_folder_by_id(id), do: Storage.get_folder(id) |> wrap_find_foder_by_id()
  defp wrap_find_foder_by_id(nil), do: {:error, :folder_not_found}
  defp wrap_find_foder_by_id(%Folder{} = folder), do: {:ok, folder}

  defp find_file_by_id(id) do
    case Storage.get_file(id) do
      nil -> {:error, :file_not_found}
      file -> {:ok, file}
    end
  end


  defp fallback(conn, {:error, :folder_not_found}), do: json(conn, %{errors: "目录不存在"})
  defp fallback(conn, {:error, :file_not_found}), do: json(conn, %{errors: "文件不存在"})
  defp fallback(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_view(WingmanWeb.ErrorView)
    |> render("error_changeset.json", changeset: changeset)
  end
  defp fallback(conn, {:error, reason}) when is_binary(reason), do: json(conn, %{errors: reason})
end
