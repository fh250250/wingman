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
      resources "/tag_groups", TagGroupController, except: [:show]
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", WingmanWeb do
  #   pipe_through :api
  # end
end
