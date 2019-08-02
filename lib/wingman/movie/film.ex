defmodule Wingman.Movie.Film do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Movie.Tag

  schema "movie_films" do
    field :title, :string
    field :desc, :string
    field :poster, :string
    field :video, :string

    many_to_many :tags, Tag, join_through: "movie_films_tags"

    timestamps()
  end

  @doc false
  def changeset(film, attrs) do
    film
    |> cast(attrs, [:title, :desc, :poster, :video])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end
