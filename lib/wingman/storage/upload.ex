defmodule Wingman.Storage.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Storage.Chunk

  schema "storage_uploads" do
    field :dir, :string
    field :md5, :string
    field :filename, :string
    field :size, :integer
    field :chunk_size, :integer, default: 4 * 1024 * 1024

    has_many :chunks, Chunk

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:dir, :md5, :filename, :size])
    |> validate_required([:dir, :md5, :filename, :size])
    |> validate_number(:size, greater_than: 0)
    |> unique_constraint(:md5, name: :storage_uploads_dir_md5_index)
  end
end
