defmodule UvdFooter.JobController do

  use UvdFooter.Web, :controller
  alias UvdFooter.JenkinsProvider

  def index(conn, _params) do
    json(conn, JenkinsProvider.get_latest(4))
  end

end
