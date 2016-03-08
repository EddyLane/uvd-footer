defmodule UvdFooter.Router do
  use UvdFooter.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UvdFooter do
    pipe_through :api

     resources "/jobs", JobController
     post "/reset", JobController, :reset
  end

  scope "/", UvdFooter do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

end
