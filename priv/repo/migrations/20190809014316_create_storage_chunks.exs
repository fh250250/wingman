defmodule Wingman.Repo.Migrations.CreateStorageChunks do
  use Ecto.Migration

  def change do
    create table(:storage_chunks) do
      add :number, :integer, null: false
      add :path, :string, null: false
      add :upload_id, references(:storage_uploads, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:storage_chunks, [:upload_id])
    create unique_index(:storage_chunks, [:number, :upload_id])
  end
end
