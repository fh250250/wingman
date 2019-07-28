defmodule Wingman.Media.Folder do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Media.File, as: MediaFile
  alias Wingman.Media.Upload

  schema "media_folders" do
    field :name, :string

    belongs_to :parent, __MODULE__
    has_many :folders, __MODULE__, foreign_key: :parent_id, references: :id
    has_many :files, MediaFile
    has_many :uploads, Upload

    timestamps()
  end

  @doc false
  def changeset(folder, attrs) do
    folder
    |> cast(attrs, [:name, :parent_id])
    |> validate_required([:name, :parent_id])
    |> foreign_key_constraint(:parent_id)
    |> unique_constraint(:name, name: :media_folders_name_parent_id_index)
  end

  def delete_changeset(folder) do
    folder
    |> change()
    |> no_assoc_constraint(:folders)
    |> no_assoc_constraint(:files)
    |> no_assoc_constraint(:uploads)
  end
end
