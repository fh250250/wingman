defmodule WingmanWeb.FormHelpers do
  @moduledoc """
  表单帮助模块
  """

  use Phoenix.HTML

  alias WingmanWeb.ErrorHelpers

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

  def array_input(form, field, label_text) do
    wrapper_opts = [class: "form-group #{state_class(form, field)}"]

    content_tag :div, wrapper_opts do
      [
        label(form, field, label_text),
        "array_input"
      ]
    end
  end
end
