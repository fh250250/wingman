defmodule Wingman.Storage.Folder do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Storage.File, as: StorageFile
  alias Wingman.Storage.Upload

  schema "storage_folders" do
    field :name, :string
    field :lft, :integer
    field :rht, :integer

    belongs_to :parent, __MODULE__
    has_many :folders, __MODULE__, foreign_key: :parent_id, references: :id
    has_many :files, StorageFile
    has_many :uploads, Upload

    timestamps()
  end

  @doc false
  def changeset(folder, attrs) do
    folder
    |> cast(attrs, [:name, :lft, :rht, :parent_id])
    |> validate_required([:name, :lft, :rht, :parent_id])
    |> foreign_key_constraint(:parent_id)
    |> unique_constraint(:name, name: :storage_folders_name_parent_id_index)
  end

  def delete_changeset(folder) do
    folder
    |> change()
    |> no_assoc_constraint(:folders, message: "无法删除, 子目录存在")
    |> no_assoc_constraint(:files, message: "无法删除, 文件存在")
    |> no_assoc_constraint(:uploads, message: "无法删除, 上传任务存在")
  end
end
