defmodule WingmanWeb.Movie.FilmController do
  use WingmanWeb, :controller

  alias Wingman.Movie
  alias Wingman.Movie.Film

  def index(conn, _params) do
    films = Movie.list_films()
    render(conn, "index.html", films: films)
  end

  def new(conn, _params) do
    conn
    |> assign(:changeset, Movie.change_film(%Film{}))
    |> assign(:tag_groups,  Movie.all_tag_groups())
    |> assign(:tag_ids, [])
    |> render("new.html")
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
        |> assign(:changeset, changeset)
        |> assign(:tag_groups,  Movie.all_tag_groups())
        |> assign(:tag_ids, film_params |> Map.get("tag_ids", []) |> Enum.map(&String.to_integer/1))
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    film = Movie.get_film!(id, :with_tags)
    changeset = Movie.change_film(film)

    conn
    |> assign(:film, film)
    |> assign(:changeset, changeset)
    |> assign(:tag_groups,  Movie.all_tag_groups())
    |> assign(:tag_ids, Enum.map(film.tags, &(&1.id)))
    |> render("edit.html")
  end

  def update(conn, %{"id" => id, "film" => film_params}) do
    film = Movie.get_film!(id, :with_tags)

    case Movie.update_film(film, film_params) do
      {:ok, _film} ->
        conn
        |> put_flash(:success, "Film updated successfully.")
        |> redirect(to: Routes.movie_film_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "更新失败")
        |> assign(:film, film)
        |> assign(:changeset, changeset)
        |> assign(:tag_groups,  Movie.all_tag_groups())
        |> assign(:tag_ids, Enum.map(film.tags, &(&1.id)))
        |> render("edit.html")
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
