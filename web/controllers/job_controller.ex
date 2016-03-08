defmodule UvdFooter.JobController do

  use UvdFooter.Web, :controller
  alias UvdFooter.JenkinsFetcher

  def index(conn, _params) do json(conn, JenkinsFetcher.get_jobs) end
  def reset(conn, _params) do json(conn, JenkinsFetcher.get_jobs(nil)) end

end
