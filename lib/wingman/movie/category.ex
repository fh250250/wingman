defmodule Wingman.Movie.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movie_categories" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end
