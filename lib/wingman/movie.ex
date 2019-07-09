defmodule Wingman.Movie do
  @moduledoc """
  The Movie context.
  """

  import Ecto.Query, warn: false

  alias Wingman.Repo
  alias Wingman.Movie.{Film, Category}


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


  def list_categories do
    Repo.all(Category)
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end
end
