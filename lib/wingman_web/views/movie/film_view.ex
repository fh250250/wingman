defmodule WingmanWeb.Movie.FilmView do
  use WingmanWeb, :view

  def tags_assoc_input(form, field, tag_groups, tag_ids) do
    tag_input_name = "#{input_name(form, field)}[]"

    ~E"""
    <div class="form-group">
      <%= label form, field, "关联标签" %>
      <table class="table table-bordered">
        <tbody>
          <%= for group <- tag_groups do %>
            <tr>
              <td style="text-align: center; vertical-align: middle"><%= group.title %></td>
              <td>
                <%= for tag <- group.tags do %>
                  <%= label style: "margin: 5px 10px; font-weight: normal" do %>
                    <%= tag :input,
                            type: "checkbox",
                            name: tag_input_name,
                            value: tag.id,
                            checked: tag.id in tag_ids,
                            data: [icheck: "blue"] %>
                    <%= tag.title %>
                  <% end %>
                <% end %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
