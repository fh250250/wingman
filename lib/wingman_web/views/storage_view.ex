defmodule WingmanWeb.StorageView do
  use WingmanWeb, :view

  alias Wingman.Storage

  def render("ls.json", %{folders: folders, files: files}) do
    %{folders: render_many(folders, __MODULE__, "folder.json", as: :folder),
      files: render_many(files, __MODULE__, "file.json", as: :file)}
  end

  def render("folder.json", %{folder: folder}) do
    %{id: folder.id,
      name: folder.name}
  end

  def render("file.json", %{file: file}) do
    %{id: file.id,
      name: file.name,
      content_type: file.content_type,
      size: file.size,
      url: Storage.public_url(file)}
  end
end
