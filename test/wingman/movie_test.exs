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
end
