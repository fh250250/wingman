defmodule Wingman.Storage.File do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Storage.Folder

  schema "storage_files" do
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
    |> validate_number(:size, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:folder_id)
    |> unique_constraint(:name, name: :storage_files_name_folder_id_index)
  end

  def delete_changeset(file) do
    file
    |> change()
    |> foreign_key_constraint(:movie_film_poster, name: :movie_films_poster_id_fkey, message: "无法删除, 已关联影片封面")
    |> foreign_key_constraint(:movie_film_video, name: :movie_films_video_id_fkey, message: "无法删除, 已关联电影视频文件")
  end
end
