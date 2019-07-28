defmodule Wingman.Repo.Migrations.CreateMediaUploads do
  use Ecto.Migration

  def change do
    create table(:media_uploads) do
      add :md5, :string, null: false
      add :filename, :string, null: false
      add :size, :bigint, null: false, default: 0
      add :chunk_size, :integer, null: false, default: 4 * 1024 * 1024
      add :folder_id, references(:media_folders), null: false

      timestamps()
    end

    create index(:media_uploads, [:folder_id])
    create unique_index(:media_uploads, [:md5, :folder_id])
  end
end
