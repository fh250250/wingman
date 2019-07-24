defmodule Wingman.Media.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Media.{Folder, UploadChunk}

  schema "media_uploads" do
    field :md5, :string
    field :filename, :string
    field :size, :integer
    field :chunk_size, :integer, default: 4 * 1024 * 1024

    belongs_to :folder, Folder
    has_many :chunks, UploadChunk

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:md5, :filename, :size, :folder_id])
    |> validate_required([:md5, :filename, :size])
    |> validate_number(:size, greater_than: 0)
    |> validate_number(:chunk_size, greater_than: 0)
    |> foreign_key_constraint(:folder_id)
    |> unique_constraint(:md5, name: :media_uploads_md5_folder_id_index)
  end
end
