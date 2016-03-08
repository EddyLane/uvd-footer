defmodule UvdFooter.JobChannel do

  use Phoenix.Channel
  alias UvdFooter.JenkinsFetcher

  def join("rooms:lobby", _message, socket) do

     send(self, :after_join)

     {:ok, socket}
  end

  def handle_info(:after_join, socket) do

    push socket, "list", %{ list: JenkinsFetcher.get_jobs }

    {:noreply, socket}
  end


end