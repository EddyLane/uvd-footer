defmodule UvdFooter.JobView do
  use UvdFooter.Web, :view

  def render("index.json", %{jobs: jobs}) do
    %{data: render_many(jobs, UvdFooter.JobView, "job.json")}
  end

  def render("show.json", %{job: job}) do
    %{data: render_one(job, UvdFooter.JobView, "job.json")}
  end

  def render("job.json", %{job: job}) do
    %{id: job.id}
  end
end
