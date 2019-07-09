defmodule WingmanWeb.Movie.CategoryController do
  use WingmanWeb, :controller

  alias Wingman.Movie
  alias Wingman.Movie.Category

  def index(conn, _params) do
    categories = Movie.list_categories()
    render(conn, "index.html", categories: categories)
  end

  def new(conn, _params) do
    changeset = Movie.change_category(%Category{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"category" => category_params}) do
    case Movie.create_category(category_params) do
      {:ok, _category} ->
        conn
        |> put_flash(:success, "Category created successfully.")
        |> redirect(to: Routes.movie_category_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "创建失败")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    category = Movie.get_category!(id)
    changeset = Movie.change_category(category)
    render(conn, "edit.html", category: category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Movie.get_category!(id)

    case Movie.update_category(category, category_params) do
      {:ok, _category} ->
        conn
        |> put_flash(:success, "Category updated successfully.")
        |> redirect(to: Routes.movie_category_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "更新失败")
        |> render("edit.html", category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Movie.get_category!(id)
    {:ok, _category} = Movie.delete_category(category)

    conn
    |> put_flash(:success, "Category deleted successfully.")
    |> redirect(to: Routes.movie_category_path(conn, :index))
  end
end
