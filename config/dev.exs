use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :uvd_footer, UvdFooter.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  cache_static_lookup: false,
  #watchers: [node: ["./node_modules/.bin/webpack-dev-server"]]
  #watchers: [node: ["node_modules/webpack/bin/webpack.js", "--watch-stdin", "--progress", "--colors"]]
  watchers: [{Path.expand("webpack.devserver.js"), []}]

# Watch static and templates for browser reloading.
config :uvd_footer, UvdFooter.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

import_config "dev.secret.exs"
