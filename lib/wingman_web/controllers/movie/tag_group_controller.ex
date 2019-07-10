defmodule WingmanWeb.Movie.TagGroupController do
  use WingmanWeb, :controller

  alias Wingman.Movie
  alias Wingman.Movie.TagGroup

  def index(conn, _params) do
    tag_groups = Movie.list_tag_groups()
    render(conn, "index.html", tag_groups: tag_groups)
  end

  def new(conn, _params) do
    changeset = Movie.change_tag_group(%TagGroup{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_group" => tag_group_params}) do
    case Movie.create_tag_group(tag_group_params) do
      {:ok, _tag_group} ->
        conn
        |> put_flash(:success, "Tag group created successfully.")
        |> redirect(to: Routes.movie_tag_group_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "创建失败")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    tag_group = Movie.get_tag_group!(id)
    changeset = Movie.change_tag_group(tag_group)
    render(conn, "edit.html", tag_group: tag_group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_group" => tag_group_params}) do
    tag_group = Movie.get_tag_group!(id)

    case Movie.update_tag_group(tag_group, tag_group_params) do
      {:ok, _tag_group} ->
        conn
        |> put_flash(:success, "Tag group updated successfully.")
        |> redirect(to: Routes.movie_tag_group_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "更新失败")
        |> render("edit.html", tag_group: tag_group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_group = Movie.get_tag_group!(id)
    {:ok, _tag_group} = Movie.delete_tag_group(tag_group)

    conn
    |> put_flash(:success, "Tag group deleted successfully.")
    |> redirect(to: Routes.movie_tag_group_path(conn, :index))
  end
end
