defmodule Wingman.Storage.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Storage.{Folder, Chunk}

  schema "storage_uploads" do
    field :md5, :string
    field :filename, :string
    field :size, :integer

    belongs_to :folder, Folder
    has_many :chunks, Chunk

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:md5, :filename, :size, :folder_id])
    |> validate_required([:md5, :filename, :size])
    |> validate_number(:size, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:folder_id)
    |> unique_constraint(:md5, name: :storage_uploads_md5_folder_id_index)
  end
end
