defmodule UvdFooter.JenkinsFetcher do

  alias UvdFooter.JenkinsProvider

  def get_jobs do
    client = get_client
    jobs = _get_jobs(client |> Exredis.query ["GET", "jobs"])
    client |> Exredis.stop
    jobs
  end

  defp _get_jobs(jobs) when is_binary(jobs) do Poison.decode!(jobs) end

  defp _get_jobs(_) do
    jobs = JenkinsProvider.get_latest(6)
    client = get_client
    client |> Exredis.query ["SET", "jobs", jobs |> Poison.encode!]
    client |> Exredis.stop
    jobs
  end

  defp redis_url do Application.get_env(:uvd_footer, :redis_url) end

  defp get_client do redis_url |> Exredis.start_using_connection_string end

end