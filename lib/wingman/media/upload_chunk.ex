defmodule Wingman.Media.UploadChunk do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Media.Upload

  schema "media_upload_chunks" do
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
    |> unique_constraint(:number, name: :media_upload_chunks_number_upload_id_index)
  end
end
