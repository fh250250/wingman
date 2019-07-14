defmodule Wingman.Movie do
  @moduledoc """
  The Movie context.
  """

  import Ecto.Query, warn: false

  alias Wingman.Repo
  alias Wingman.Movie.{Film, TagGroup}


  def list_films do
    Repo.all(Film)
  end

  def get_film!(id), do: Repo.get!(Film, id)

  def create_film(attrs \\ %{}) do
    %Film{}
    |> Film.changeset(attrs)
    |> Repo.insert()
  end

  def update_film(%Film{} = film, attrs) do
    film
    |> Film.changeset(attrs)
    |> Repo.update()
  end

  def delete_film(%Film{} = film) do
    Repo.delete(film)
  end

  def change_film(%Film{} = film) do
    Film.changeset(film, %{})
  end




  def list_tag_groups do
    Repo.all(TagGroup)
  end

  def get_tag_group!(id), do: Repo.get!(TagGroup, id) |> Repo.preload(:tags)

  def create_tag_group(attrs \\ %{}) do
    %TagGroup{}
    |> TagGroup.changeset(attrs)
    |> Repo.insert()
  end

  def update_tag_group(%TagGroup{} = tag_group, attrs) do
    tag_group
    |> TagGroup.changeset(attrs)
    |> Repo.update()
  end

  def delete_tag_group(%TagGroup{} = tag_group) do
    Repo.delete(tag_group)
  end

  def change_tag_group(%TagGroup{} = tag_group) do
    TagGroup.changeset(tag_group, %{})
  end
end
