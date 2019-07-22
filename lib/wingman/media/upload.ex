defmodule Wingman.Media.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Media.{Folder, UploadChunk}

  schema "media_uploads" do
    field :md5, :string
    field :filename, :string
    field :size, :integer
    field :chunk_size, :integer

    belongs_to :folder, Folder
    has_many :chunks, UploadChunk

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:md5, :filename, :size, :chunk_size, :folder_id])
    |> validate_required([:md5, :filename, :size, :chunk_size])
    |> foreign_key_constraint(:folder_id)
    |> unique_constraint(:md5, name: :media_uploads_md5_folder_id_index)
  end
end
