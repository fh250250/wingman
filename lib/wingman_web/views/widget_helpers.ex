defmodule WingmanWeb.WidgetHelpers do
  @moduledoc """
  小部件
  """

  use Phoenix.HTML

  def vue_widget(name, data \\ %{}) do
    content_tag :div, data: [vue: name] do
      [
        content_tag(:div, Jason.encode!(data)),
        content_tag(:i, nil, class: "fa fa-cog fa-spin fa-fw fa-4x")
      ]
    end
  end
end
