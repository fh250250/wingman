defmodule Wingman.Storage.Chunk do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Storage.Upload

  schema "storage_chunks" do
    field :number, :integer
    field :path, :string

    belongs_to :upload, Upload

    timestamps()
  end

  @doc false
  def changeset(chunk, attrs) do
    chunk
    |> cast(attrs, [:number, :path, :upload_id])
    |> validate_required([:number, :path])
    |> validate_number(:number, greater_than: 0)
    |> foreign_key_constraint(:upload_id)
    |> unique_constraint(:number, name: :storage_chunks_number_upload_id_index)
  end
end
