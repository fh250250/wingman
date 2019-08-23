defmodule WingmanWeb.Router do
  use WingmanWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WingmanWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/movie", Movie, as: :movie do
      resources "/films", FilmController, except: [:show]
      resources "/tag-groups", TagGroupController, except: [:show]
    end

    scope "/storage" do
      get "/", StorageController, :index
      get "/file/:id", StorageController, :show_file

      post "/ls", StorageController, :ls
      post "/ls-folders", StorageController, :ls_folders
      post "/mkdir", StorageController, :mkdir
      post "/rmdir", StorageController, :rmdir
      post "/rename-folder", StorageController, :rename_folder
      post "/rename-file", StorageController, :rename_file
      post "/move-folder", StorageController, :move_folder
      post "/move-file", StorageController, :move_file
      post "/rm", StorageController, :rm
      post "/small-upload", StorageController, :small_upload
      post "/large-upload", StorageController, :large_upload
      post "/chunk", StorageController, :chunk
      post "/combine", StorageController, :combine
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", WingmanWeb do
  #   pipe_through :api
  # end
end
