defmodule Wingman.Repo.Migrations.CreateMovieTagGroups do
  use Ecto.Migration

  def change do
    create table(:movie_tag_groups) do
      add :title, :string, null: false

      timestamps()
    end

    create unique_index(:movie_tag_groups, [:title])
  end
end
