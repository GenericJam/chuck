defmodule Chuck.Application do
  use Application

  require Logger

  def start(_type, _args) do
    # List child processes to be supervised
    children = [
      # Registry.child_spec(keys: :duplicate, name: Registry.Chuck),
      # Wrapper around all User clients
      {Chuck.UserApplication, []},
      # Handles all API interactions
      {Chuck.JokeGenServer, []},
      endpoint()
    ]

    Logger.debug(Application.get_all_env(:chuck))

    opts = [strategy: :one_for_one, name: Chuck.MainSupervisor]
    Supervisor.start_link(children, opts)
  end

  defp endpoint() do
    {Plug.Cowboy,
     scheme: Application.get_env(:chuck, :scheme),
     plug: Chuck.Endpoint,
     options: [
       port: Application.get_env(:chuck, :port),
       dispatch: [
         {:_,
          [
            # Endpoint for websocket to connect to to interact with jokes
            {"/jokes/[...]", Chuck.Websocket, []},

            # Other HTTP routes
            {:_, Plug.Cowboy.Handler, {Chuck.Endpoint, []}}
          ]}
       ]
     ]}
  end
end
