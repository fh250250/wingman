defmodule Wingman.Movie.Film do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movie_films" do
    field :title, :string
    field :desc, :string
    field :poster, :string
    field :video, :string

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
