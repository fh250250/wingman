defmodule Wingman.Repo.Migrations.CreateMovieCategories do
  use Ecto.Migration

  def change do
    create table(:movie_categories) do
      add :title, :string, null: false

      timestamps()
    end

    create unique_index(:movie_categories, [:title])
  end
end
