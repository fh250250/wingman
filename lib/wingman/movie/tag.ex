defmodule Wingman.Movie.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Movie.{TagGroup, Film}

  schema "movie_tags" do
    field :title, :string

    belongs_to :group, TagGroup
    many_to_many :films, Film, join_through: "movie_films_tags"

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:title, :group_id])
    |> validate_required([:title])
    |> foreign_key_constraint(:group_id)
    |> unique_constraint(:title, name: :movie_tags_title_group_id_index)
  end
end
