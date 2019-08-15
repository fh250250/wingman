defmodule Wingman.Repo.Migrations.CreateStorage do
  use Ecto.Migration

  def change do
    # 目录
    create table(:storage_folders) do
      add :name, :string, null: false
      add :lft, :integer, null: false
      add :rht, :integer, null: false
      add :parent_id, references(:storage_folders)

      timestamps()
    end

    create index(:storage_folders, [:parent_id])
    create unique_index(:storage_folders, [:name, :parent_id])


    # 文件
    create table(:storage_files) do
      add :name, :string, null: false
      add :size, :bigint, null: false
      add :content_type, :string, null: false
      add :path, :string, null: false
      add :folder_id, references(:storage_folders), null: false

      timestamps()
    end

    create index(:storage_files, [:folder_id])
    create unique_index(:storage_files, [:name, :folder_id])


    # 上传任务
    create table(:storage_uploads) do
      add :md5, :string, null: false
      add :filename, :string, null: false
      add :size, :bigint, null: false
      add :chunk_size, :integer, null: false
      add :folder_id, references(:storage_folders), null: false

      timestamps()
    end

    create index(:storage_uploads, [:folder_id])
    create unique_index(:storage_uploads, [:md5, :folder_id])


    # 上传分块
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
