defmodule WingmanWeb.PageController do
  use WingmanWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def app_editor(conn, _params) do
    conn
    |> put_layout(false)
    |> render("app_editor.html")
  end
end
