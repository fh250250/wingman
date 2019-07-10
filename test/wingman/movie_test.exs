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

  describe "tag_groups" do
    alias Wingman.Movie.TagGroup

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def tag_group_fixture(attrs \\ %{}) do
      {:ok, tag_group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Movie.create_tag_group()

      tag_group
    end

    test "list_tag_groups/0 returns all tag_groups" do
      tag_group = tag_group_fixture()
      assert Movie.list_tag_groups() == [tag_group]
    end

    test "get_tag_group!/1 returns the tag_group with given id" do
      tag_group = tag_group_fixture()
      assert Movie.get_tag_group!(tag_group.id) == tag_group
    end

    test "create_tag_group/1 with valid data creates a tag_group" do
      assert {:ok, %TagGroup{} = tag_group} = Movie.create_tag_group(@valid_attrs)
      assert tag_group.title == "some title"
    end

    test "create_tag_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Movie.create_tag_group(@invalid_attrs)
    end

    test "update_tag_group/2 with valid data updates the tag_group" do
      tag_group = tag_group_fixture()
      assert {:ok, %TagGroup{} = tag_group} = Movie.update_tag_group(tag_group, @update_attrs)
      assert tag_group.title == "some updated title"
    end

    test "update_tag_group/2 with invalid data returns error changeset" do
      tag_group = tag_group_fixture()
      assert {:error, %Ecto.Changeset{}} = Movie.update_tag_group(tag_group, @invalid_attrs)
      assert tag_group == Movie.get_tag_group!(tag_group.id)
    end

    test "delete_tag_group/1 deletes the tag_group" do
      tag_group = tag_group_fixture()
      assert {:ok, %TagGroup{}} = Movie.delete_tag_group(tag_group)
      assert_raise Ecto.NoResultsError, fn -> Movie.get_tag_group!(tag_group.id) end
    end

    test "change_tag_group/1 returns a tag_group changeset" do
      tag_group = tag_group_fixture()
      assert %Ecto.Changeset{} = Movie.change_tag_group(tag_group)
    end
  end
end
