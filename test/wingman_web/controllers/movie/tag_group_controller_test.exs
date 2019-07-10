defmodule WingmanWeb.Movie.TagGroupControllerTest do
  use WingmanWeb.ConnCase

  alias Wingman.Movie

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  def fixture(:tag_group) do
    {:ok, tag_group} = Movie.create_tag_group(@create_attrs)
    tag_group
  end

  describe "index" do
    test "lists all tag_groups", %{conn: conn} do
      conn = get(conn, Routes.movie_tag_group_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tag groups"
    end
  end

  describe "new tag_group" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.movie_tag_group_path(conn, :new))
      assert html_response(conn, 200) =~ "New Tag group"
    end
  end

  describe "create tag_group" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.movie_tag_group_path(conn, :create), tag_group: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.movie_tag_group_path(conn, :show, id)

      conn = get(conn, Routes.movie_tag_group_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Tag group"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.movie_tag_group_path(conn, :create), tag_group: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tag group"
    end
  end

  describe "edit tag_group" do
    setup [:create_tag_group]

    test "renders form for editing chosen tag_group", %{conn: conn, tag_group: tag_group} do
      conn = get(conn, Routes.movie_tag_group_path(conn, :edit, tag_group))
      assert html_response(conn, 200) =~ "Edit Tag group"
    end
  end

  describe "update tag_group" do
    setup [:create_tag_group]

    test "redirects when data is valid", %{conn: conn, tag_group: tag_group} do
      conn = put(conn, Routes.movie_tag_group_path(conn, :update, tag_group), tag_group: @update_attrs)
      assert redirected_to(conn) == Routes.movie_tag_group_path(conn, :show, tag_group)

      conn = get(conn, Routes.movie_tag_group_path(conn, :show, tag_group))
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, tag_group: tag_group} do
      conn = put(conn, Routes.movie_tag_group_path(conn, :update, tag_group), tag_group: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Tag group"
    end
  end

  describe "delete tag_group" do
    setup [:create_tag_group]

    test "deletes chosen tag_group", %{conn: conn, tag_group: tag_group} do
      conn = delete(conn, Routes.movie_tag_group_path(conn, :delete, tag_group))
      assert redirected_to(conn) == Routes.movie_tag_group_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.movie_tag_group_path(conn, :show, tag_group))
      end
    end
  end

  defp create_tag_group(_) do
    tag_group = fixture(:tag_group)
    {:ok, tag_group: tag_group}
  end
end
