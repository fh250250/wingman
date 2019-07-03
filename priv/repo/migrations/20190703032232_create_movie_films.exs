defmodule Wingman.Repo.Migrations.CreateMovieFilms do
  use Ecto.Migration

  def change do
    create table(:movie_films) do
      add :title, :string, null: false
      add :desc, :text

      timestamps()
    end

    create unique_index(:movie_films, [:title])
  end
end
