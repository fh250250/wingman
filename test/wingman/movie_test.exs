defmodule Wingman.MovieTest do
  use Wingman.DataCase

  alias Wingman.Movie

  describe "films" do
    alias Wingman.Movie.Film

    @valid_attrs %{desc: "some desc", title: "some title"}
    @update_attrs %{desc: "some updated desc", title: "some updated title"}
    @invalid_attrs %{desc: nil, title: nil}

    def film_fixture(attrs \\ %{}) do
      {:ok, film} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Movie.create_film()

      film
    end

    test "list_films/0 returns all films" do
      film = film_fixture()
      assert Movie.list_films() == [film]
    end

    test "get_film!/1 returns the film with given id" do
      film = film_fixture()
      assert Movie.get_film!(film.id) == film
    end

    test "create_film/1 with valid data creates a film" do
      assert {:ok, %Film{} = film} = Movie.create_film(@valid_attrs)
      assert film.desc == "some desc"
      assert film.title == "some title"
    end

    test "create_film/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Movie.create_film(@invalid_attrs)
    end

    test "update_film/2 with valid data updates the film" do
      film = film_fixture()
      assert {:ok, %Film{} = film} = Movie.update_film(film, @update_attrs)
      assert film.desc == "some updated desc"
      assert film.title == "some updated title"
    end

    test "update_film/2 with invalid data returns error changeset" do
      film = film_fixture()
      assert {:error, %Ecto.Changeset{}} = Movie.update_film(film, @invalid_attrs)
      assert film == Movie.get_film!(film.id)
    end

    test "delete_film/1 deletes the film" do
      film = film_fixture()
      assert {:ok, %Film{}} = Movie.delete_film(film)
      assert_raise Ecto.NoResultsError, fn -> Movie.get_film!(film.id) end
    end

    test "change_film/1 returns a film changeset" do
      film = film_fixture()
      assert %Ecto.Changeset{} = Movie.change_film(film)
    end
  end

  describe "categories" do
    alias Wingman.Movie.Category

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Movie.create_category()

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Movie.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Movie.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Movie.create_category(@valid_attrs)
      assert category.title == "some title"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Movie.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Movie.update_category(category, @update_attrs)
      assert category.title == "some updated title"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Movie.update_category(category, @invalid_attrs)
      assert category == Movie.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Movie.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Movie.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Movie.change_category(category)
    end
  end
end
