defmodule WingmanWeb.Movie.TagGroupView do
  use WingmanWeb, :view

  def tags_input(form) do
    list_json =
    form.impl.to_form(form.source, form, :tags, [])
    |> Enum.map(fn f -> %{
      id: input_value(f, :id),
      title: input_value(f, :title),
      action: form.source.action,
      errors: errors_map(f)
    } end)
    |> Jason.encode!()

    content_tag :div, class: "form-group" do
      [
        label(form, :tags, "标签管理"),
        content_tag(:div, nil, data: [
          vue: "tags_input",
          name: "#{form.name}[tags]",
          list: list_json
        ])
      ]
    end
  end
end
