defmodule Wingman.Movie.Film do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movie_films" do
    field :title, :string
    field :desc, :string

    timestamps()
  end

  @doc false
  def changeset(film, attrs) do
    film
    |> cast(attrs, [:title, :desc])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end
