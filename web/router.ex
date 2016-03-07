defmodule UvdFooter.Router do
  use UvdFooter.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UvdFooter do
    pipe_through :api

     resources "/jobs", JobController
     post "/reset", JobController, :reset
  end

end
