defmodule Mix.Tasks.UvdFooter.Digest do
  use Mix.Task

  def run(_args) do
    Mix.Shell.IO.cmd "./node_modules/webpack/bin/webpack.js"
  end
end