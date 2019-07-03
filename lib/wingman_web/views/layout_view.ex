defmodule WingmanWeb.LayoutView do
  use WingmanWeb, :view

  def flash_messages(conn) do
    for {key, message} <- get_flash(conn) do
      ~E"""
      <div class="alert alert-<%= key %> alert-dismissible">
        <button type="button" class="close" data-dismiss="alert">×</button>
        <%= message %>
      </div>
      """
    end
  end
end
