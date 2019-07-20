defmodule WingmanWeb.Movie.TagGroupView do
  use WingmanWeb, :view

  def tags_input(form, field) do
    errors =
      form.source
      |> errors_map()
      |> Map.get(field)

    list =
      form.source
      |> Ecto.Changeset.get_field(field)
      |> Enum.with_index()
      |> Enum.map(fn {t, idx} ->
        e = if errors, do: Enum.at(errors, idx), else: nil

        %{id: t.id,
          title: t.title,
          action: form.source.action,
          errors: e}
      end)

    content_tag :div, class: "form-group" do
      [
        label(form, field, "标签管理"),
        vue_widget(:tags_input, %{
          name: "#{form.name}[#{field}]",
          list: list
        })
      ]
    end
  end
end
