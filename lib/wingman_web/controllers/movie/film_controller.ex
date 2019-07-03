defmodule WingmanWeb.Movie.FilmController do
  use WingmanWeb, :controller

  alias Wingman.Movie
  alias Wingman.Movie.Film

  def index(conn, _params) do
    films = Movie.list_films()
    render(conn, "index.html", films: films)
  end

  def new(conn, _params) do
    changeset = Movie.change_film(%Film{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"film" => film_params}) do
    case Movie.create_film(film_params) do
      {:ok, _film} ->
        conn
        |> put_flash(:success, "Film created successfully.")
        |> redirect(to: Routes.movie_film_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "创建失败")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    film = Movie.get_film!(id)
    changeset = Movie.change_film(film)
    render(conn, "edit.html", film: film, changeset: changeset)
  end

  def update(conn, %{"id" => id, "film" => film_params}) do
    film = Movie.get_film!(id)

    case Movie.update_film(film, film_params) do
      {:ok, _film} ->
        conn
        |> put_flash(:success, "Film updated successfully.")
        |> redirect(to: Routes.movie_film_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "更新失败")
        render(conn, "edit.html", film: film, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    film = Movie.get_film!(id)
    {:ok, _film} = Movie.delete_film(film)

    conn
    |> put_flash(:success, "Film deleted successfully.")
    |> redirect(to: Routes.movie_film_path(conn, :index))
  end
end
