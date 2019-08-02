defmodule Wingman.Repo.Migrations.CreateMovieFilmsTags do
  use Ecto.Migration

  def change do
    create table(:movie_films_tags, primary_key: false) do
      add :film_id, references(:movie_films, on_delete: :delete_all), null: false
      add :tag_id, references(:movie_tags, on_delete: :delete_all), null: false
    end

    create index(:movie_films_tags, [:film_id])
    create index(:movie_films_tags, [:tag_id])
    create unique_index(:movie_films_tags, [:film_id, :tag_id])
  end
end
