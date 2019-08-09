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

    scope "/media" do
      get "/", MediaController, :index
      get "/ls", MediaController, :ls
      get "/folders", MediaController, :all_folders

      post "/mkdir", MediaController, :mkdir
      post "/folder", MediaController, :update_folder
      delete "/folder", MediaController, :delete_folder

      post "/upload", MediaController, :upload
      post "/upload/task", MediaController, :upload_task
      post "/upload/chunk", MediaController, :upload_chunk
      post "/upload/combine", MediaController, :upload_combine
      post "/file", MediaController, :update_file
      delete "/file", MediaController, :delete_file
    end

    scope "/storage" do
      get "/", StorageController, :index

      post "/ls", StorageController, :ls
      post "/mkdir", StorageController, :mkdir
      post "/upload", StorageController, :upload
      post "/rename", StorageController, :rename
      post "/rmdir", StorageController, :rmdir
      post "/rm", StorageController, :rm
      post "/task", StorageController, :task
      post "/chunk", StorageController, :chunk
      post "/combine", StorageController, :combine
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", WingmanWeb do
  #   pipe_through :api
  # end
end
