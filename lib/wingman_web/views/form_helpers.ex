defmodule WingmanWeb.FormHelpers do
  @moduledoc """
  表单帮助模块
  """

  use Phoenix.HTML

  alias WingmanWeb.{ErrorHelpers, WidgetHelpers}

  defp state_class(form, field) do
    cond do
      !form.source.action -> ""
      form.errors[field] -> "has-error"
      true -> "has-success"
    end
  end

  def simple_input(form, field, label_text, input, opts \\ []) do
    wrapper_opts = [class: "form-group #{state_class(form, field)}"]
    input_opts = Keyword.merge([class: "form-control"], opts)

    content_tag :div, wrapper_opts do
      [
        label(form, field, label_text),
        apply(Phoenix.HTML.Form, input, [form, field, input_opts]),
        ErrorHelpers.error_tag(form, field)
      ]
    end
  end

  def storage_input(form, field, label_text) do
    wrapper_opts = [class: "form-group #{state_class(form, field)}"]

    content_tag :div, wrapper_opts do
      [
        label(form, field, label_text),
        WidgetHelpers.vue_widget(:storage_input, %{
          form_name: input_name(form, field),
          form_value: input_value(form, field)
        }),
        ErrorHelpers.error_tag(form, field)
      ]
    end
  end
end
