defmodule UvdFooter.JobController do

  use UvdFooter.Web, :controller
  alias UvdFooter.JenkinsFetcher

  def index(conn, _params) do json(conn, JenkinsFetcher.get_jobs) end
  def reset(conn, _params) do
    jobs = JenkinsFetcher.get_jobs(nil)
    UvdFooter.Endpoint.broadcast("rooms:lobby", "list", %{ list: JenkinsFetcher.get_jobs })
    json(conn, jobs)
  end

end
