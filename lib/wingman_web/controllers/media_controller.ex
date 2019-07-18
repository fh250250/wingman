defmodule WingmanWeb.MediaController do
  use WingmanWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
