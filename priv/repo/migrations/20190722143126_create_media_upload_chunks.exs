defmodule Wingman.Repo.Migrations.CreateMediaUploadChunks do
  use Ecto.Migration

  def change do
    create table(:media_upload_chunks) do
      add :number, :integer, null: false
      add :path, :string, null: false
      add :upload_id, references(:media_uploads, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:media_upload_chunks, [:upload_id])
    create unique_index(:media_upload_chunks, [:number, :upload_id])
  end
end
