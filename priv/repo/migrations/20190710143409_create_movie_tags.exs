defmodule Wingman.Repo.Migrations.CreateMovieTags do
  use Ecto.Migration

  def change do
    create table(:movie_tags) do
      add :title, :string, null: false
      add :group_id, references(:movie_tag_groups, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:movie_tags, [:group_id])
    create unique_index(:movie_tags, [:title, :group_id])
  end
end
