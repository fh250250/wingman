defmodule Wingman.Movie.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wingman.Movie.TagGroup

  schema "movie_tags" do
    field :title, :string

    belongs_to :group, TagGroup

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:title, :group_id])
    |> validate_required([:title, :group_id])
    |> foreign_key_constraint(:group_id)
    |> unique_constraint(:title, name: :movie_tags_title_group_id_index)
  end
end
