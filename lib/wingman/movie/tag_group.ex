defmodule Wingman.Movie.TagGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movie_tag_groups" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(tag_group, attrs) do
    tag_group
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end
