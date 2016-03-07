defmodule UvdFooter.JobController do

  use UvdFooter.Web, :controller
  alias UvdFooter.JenkinsProvider

  def index(conn, _params) do json(conn, get_jobs) end
  def reset(conn, _params) do

    IO.puts conn.remote_ip

    json(conn, get_jobs(nil))

  end

  defp get_jobs do
    jobs = get_jobs(client |> Exredis.query ["GET", "jobs"])
    client |> Exredis.stop
    jobs
  end

  defp get_jobs(jobs) when is_binary(jobs) do Poison.decode!(jobs) end

  defp get_jobs(_) do
    jobs = JenkinsProvider.get_latest(4)
    client |> Exredis.query ["SET", "jobs", jobs |> Poison.encode!]
    jobs
  end

  defp redis_url do Application.get_env(:uvd_footer, :redis_url) end

  defp client do redis_url |> Exredis.start_using_connection_string end

end
