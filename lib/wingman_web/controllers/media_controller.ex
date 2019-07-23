defmodule WingmanWeb.MediaController do
  use WingmanWeb, :controller

  alias Wingman.Media

  @ensure_folder_actions [:ls, :mkdir, :upload, :upload_task]

  def action(conn, _) do
    cond do
      action_name(conn) in @ensure_folder_actions -> :ensure_folder
      true -> :normal
    end
    |> dispatch_action(conn)
  end

  def dispatch_action(:normal, conn), do: apply(__MODULE__, action_name(conn), [conn, conn.params])
  def dispatch_action(:ensure_folder, conn) do
    case conn.params["folder_id"] do
      nil -> Media.get_folder()
      id -> Media.get_folder(id)
    end
    |> case do
      nil -> json(conn, %{errors: "上级目录不存在"})
      folder -> apply(__MODULE__, action_name(conn), [conn, conn.params, folder])
    end
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def ls(conn, _params, folder) do
    folder = Media.list_folder(folder)

    render(conn, "ls.json", folders: folder.folders, files: folder.files)
  end

  def mkdir(conn, %{"folder" => folder_params}, folder) do
    case Media.create_folder(folder, folder_params) do
      {:ok, new_folder} ->
        render(conn, "folder.json", folder: new_folder)
      {:error, changeset} ->
        conn
        |> put_view(WingmanWeb.ErrorView)
        |> render("error_changeset.json", changeset: changeset)
    end
  end

  def upload(conn, %{"file" => %Plug.Upload{} = upload_file}, folder) do
    case Media.save_file(folder, upload_file) do
      {:ok, %{create_file: new_file}} ->
        render(conn, "file.json", file: new_file)
      {:error, :create_file, changeset, _} ->
        conn
        |> put_view(WingmanWeb.ErrorView)
        |> render("error_changeset.json", changeset: changeset)
      {:error, _, reason, _} ->
        json(conn, %{errors: reason})
    end
  end

  def upload_task(conn, %{"upload" => upload_params}, folder) do
    case Media.get_or_create_upload(folder, upload_params) do
      {:ok, %{upload: upload, chunks: chunks}} ->
        json(conn, %{upload_id: upload.id, chunks: chunks})
      {:error, changeset} ->
        conn
        |> put_view(WingmanWeb.ErrorView)
        |> render("error_changeset.json", changeset: changeset)
    end
  end

  def upload_chunk(conn, %{"number" => number, "upload_id" => upload_id, "chunk" => %Plug.Upload{} = chunk}) do
    case Media.save_chunk(%{number: number, upload_id: upload_id}, chunk) do
      {:ok, %{create_chunk: new_chunk}} ->
        json(conn, %{id: new_chunk.id, number: new_chunk.number})
      {:error, :create_chunk, changeset, _} ->
        conn
        |> put_view(WingmanWeb.ErrorView)
        |> render("error_changeset.json", changeset: changeset)
      {:error, _, reason, _} ->
        json(conn, %{errors: reason})
    end
  end

  def upload_combine(conn, %{"upload_id" => upload_id}) do
    case Media.combine_chunks(upload_id) do
      {:ok, new_file} ->
        render(conn, "file.json", file: new_file)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(WingmanWeb.ErrorView)
        |> render("error_changeset.json", changeset: changeset)
      {:error, reason} ->
        json(conn, %{errors: reason})
    end
  end
end
