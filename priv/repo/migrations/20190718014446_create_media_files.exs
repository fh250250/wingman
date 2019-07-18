defmodule Wingman.Repo.Migrations.CreateMediaFiles do
  use Ecto.Migration

  def change do
    create table(:media_files) do
      add :name, :string, null: false
      add :size, :bigint, null: false, default: 0
      add :content_type, :string, null: false
      add :path, :string, null: false
      add :folder_id, references(:media_folders, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:media_files, [:folder_id])
    create unique_index(:media_files, [:name, :folder_id])
  end
end
