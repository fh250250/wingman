defmodule Wingman.Media.Folder do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Media.File, as: MediaFile

  schema "media_folders" do
    field :name, :string

    belongs_to :parent, __MODULE__
    has_many :folders, __MODULE__, foreign_key: :parent_id, references: :id
    has_many :files, MediaFile

    timestamps()
  end

  @doc false
  def changeset(folder, attrs) do
    folder
    |> cast(attrs, [:name, :parent_id])
    |> validate_required([:name])
    |> foreign_key_constraint(:parent_id)
    |> unique_constraint(:name, name: :media_folders_name_parent_id_index)
  end
end
