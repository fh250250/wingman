defmodule Wingman.Media.File do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Media.Folder

  schema "media_files" do
    field :name, :string
    field :size, :integer
    field :content_type, :string
    field :path, :string

    belongs_to :folder, Folder

    timestamps()
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:name, :size, :content_type, :path, :folder_id])
    |> validate_required([:name, :size, :content_type, :path])
    |> foreign_key_constraint(:folder_id)
    |> unique_constraint(:name, name: :media_files_name_folder_id_index)
  end
end
