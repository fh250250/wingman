defmodule WingmanWeb.StorageController do
  use WingmanWeb, :controller

  alias Wingman.Storage

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def ls(conn, %{"path" => path}) do
    case Storage.ls(path) do
      {:ok, items} -> json(conn, %{list: items})
      {:error, reason} -> json(conn, %{errors: reason})
    end
  end

  def mkdir(conn, %{"path" => path}) do
    case Storage.mkdir(path) do
      :ok -> json(conn, %{ok: true})
      {:error, reason} -> json(conn, %{errors: reason})
    end
  end

  def upload(conn, %{"path" => path, "file" => %Plug.Upload{} = file}) do
    case Storage.save_file(path, file) do
      :ok -> json(conn, %{ok: true})
      {:error, reason} -> json(conn, %{errors: reason})
    end
  end

  def rename(conn, %{"from" => from, "to" => to}) do
    case Storage.rename(from, to) do
      :ok -> json(conn, %{ok: true})
      {:error, reason} -> json(conn, %{errors: reason})
    end
  end

  def rmdir(conn, %{"path" => path}) do
    case Storage.rmdir(path) do
      :ok -> json(conn, %{ok: true})
      {:error, reason} -> json(conn, %{errors: reason})
    end
  end

  def rm(conn, %{"path" => path}) do
    case Storage.rm(path) do
      :ok -> json(conn, %{ok: true})
      {:error, reason} -> json(conn, %{errors: reason})
    end
  end

  def task(conn, %{"upload" => upload_params}) do
    case Storage.get_or_create_upload(upload_params) do
      {:ok, {upload, chunks}} ->
        json(conn, %{id: upload.id, chunks: chunks})
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(WingmanWeb.ErrorView)
        |> render("error_changeset.json", changeset: changeset)
      {:error, reason} ->
        json(conn, %{errors: reason})
    end
  end

  def chunk(conn, %{"number" => number, "upload_id" => upload_id, "chunk" => %Plug.Upload{} = chunk_file}) do
    case Storage.save_chunk(%{number: number, upload_id: upload_id}, chunk_file) do
      {:ok, new_chunk} ->
        json(conn, %{id: new_chunk.id, number: new_chunk.number})
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(WingmanWeb.ErrorView)
        |> render("error_changeset.json", changeset: changeset)
      {:error, reason} ->
        json(conn, %{errors: reason})
    end
  end

  def combine(conn, %{"upload_id" => upload_id}) do
    case Storage.combine_chunks(upload_id) do
      :ok -> json(conn, %{ok: true})
      {:error, reason} -> json(conn, %{errors: reason})
    end
  end
end
