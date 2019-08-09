defmodule Wingman.Repo.Migrations.CreateStorageUploads do
  use Ecto.Migration

  def change do
    create table(:storage_uploads) do
      add :dir, :string, null: false
      add :md5, :string, null: false
      add :filename, :string, null: false
      add :size, :bigint, null: false
      add :chunk_size, :integer, null: false

      timestamps()
    end

    create index(:storage_uploads, [:dir])
    create unique_index(:storage_uploads, [:dir, :md5])
  end
end
