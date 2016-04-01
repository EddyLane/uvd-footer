defmodule UvdFooter.Mixfile do
  use Mix.Project

  def project do
    [app: :uvd_footer,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     aliases: ["phoenix.digest": ["uvd_footer.digest", "phoenix.digest"]]]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {UvdFooter, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext, :httpotion, :xmerl, :timex, :exredis, :cors_plug]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.1.4"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.2"},
     {:timex, "~> 2.0"},
     {:cors_plug, "~> 1.1"},
     {:exredis, github: "artemeff/exredis"},
     {:httpotion, "~> 2.1.0"}]
  end
end
