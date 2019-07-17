defmodule WingmanWeb.Movie.TagGroupView do
  use WingmanWeb, :view

  def tags_input(form, field) do
    list_json =
      form.source
      |> Ecto.Changeset.get_field(field)
      |> Enum.map(fn t -> %{
        id: t.id,
        title: t.title,
        action: form.source.action
      } end)
      |> Jason.encode!()

    errors_json =
      form.source
      |> errors_map()
      |> Map.get(field)
      |> Jason.encode!()

    content_tag :div, class: "form-group" do
      [
        label(form, field, "标签管理"),
        content_tag(:div, nil, data: [
          vue: "tags_input",
          name: "#{form.name}[#{field}]",
          list: list_json,
          errors: errors_json
        ])
      ]
    end
  end
end
