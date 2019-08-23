defmodule Wingman.Movie.Film do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Wingman.Repo
  alias Wingman.Movie.Tag

  schema "movie_films" do
    field :title, :string
    field :desc, :string
    field :poster_id, :id
    field :video_id, :id

    many_to_many :tags, Tag, join_through: "movie_films_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(film, attrs) do
    film
    |> cast(attrs, [:title, :desc, :poster_id, :video_id])
    |> validate_required([:title, :poster_id, :video_id])
    |> unique_constraint(:title)
    |> foreign_key_constraint(:poster_id)
    |> foreign_key_constraint(:video_id)
  end

  def change_tags(changeset, attrs) do
    tags =
      attrs
      |> Map.get("tag_ids", nil)
      |> case do
        nil -> []
        ids -> from(t in Tag, where: t.id in ^ids) |> Repo.all()
      end

    put_assoc(changeset, :tags, tags)
  end
end
