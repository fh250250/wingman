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
  def get_film!(id, :with_tags), do: get_film!(id) |> Repo.preload(:tags)

  def create_film(attrs \\ %{}) do
    %Film{}
    |> Film.changeset(attrs)
    |> Film.change_tags(attrs)
    |> Repo.insert()
  end

  def update_film(%Film{} = film, attrs) do
    film
    |> Film.changeset(attrs)
    |> Film.change_tags(attrs)
    |> Repo.update()
  end

  def delete_film(%Film{} = film) do
    Repo.delete(film)
  end

  def change_film(%Film{} = film) do
    Film.changeset(film, %{})
  end




  @doc """
  获取所有 tag_groups 及 tags
  """
  def list_tag_groups() do
    TagGroup |> Repo.all() |> Repo.preload(:tags)
  end

  def get_tag_group!(id), do: Repo.get!(TagGroup, id)
  def get_tag_group!(id, :with_tags), do: get_tag_group!(id) |> Repo.preload(:tags)

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
