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
      {:ok, film} ->
        conn
        |> put_flash(:info, "Film created successfully.")
        |> redirect(to: Routes.movie_film_path(conn, :show, film))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    film = Movie.get_film!(id)
    render(conn, "show.html", film: film)
  end

  def edit(conn, %{"id" => id}) do
    film = Movie.get_film!(id)
    changeset = Movie.change_film(film)
    render(conn, "edit.html", film: film, changeset: changeset)
  end

  def update(conn, %{"id" => id, "film" => film_params}) do
    film = Movie.get_film!(id)

    case Movie.update_film(film, film_params) do
      {:ok, film} ->
        conn
        |> put_flash(:info, "Film updated successfully.")
        |> redirect(to: Routes.movie_film_path(conn, :show, film))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", film: film, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    film = Movie.get_film!(id)
    {:ok, _film} = Movie.delete_film(film)

    conn
    |> put_flash(:info, "Film deleted successfully.")
    |> redirect(to: Routes.movie_film_path(conn, :index))
  end
end
