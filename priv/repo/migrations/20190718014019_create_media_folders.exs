defmodule Wingman.Repo.Migrations.CreateMediaFolders do
  use Ecto.Migration

  def change do
    create table(:media_folders) do
      add :name, :string, null: false
      add :parent_id, references(:media_folders, on_delete: :delete_all)

      timestamps()
    end

    create index(:media_folders, [:parent_id])
    create unique_index(:media_folders, [:name, :parent_id])
  end
end
