defmodule Chuck.Endpoint do
  use Plug.Router

  require Logger



  # Lumberjack
  plug(Plug.Logger)

  # Match routes
  plug(:match)

  # This is the parser we'll use
  plug(Plug.Parsers,
    parsers: [:json, :urlencoded],
    pass: ["application/json"],
    json_decoder: Jason
  )

  # Dispatch responses
  plug(:dispatch)

  # It's alive
  get "/" do
    Logger.debug("Getting request")
    index = File.read!("priv/static/index.html")
    send_resp(conn, 200, index)
  end

  # Otherwise it's 404!
  match _ do
    Logger.info("404")
    send_resp(conn, 404, "It was here a minute ago... did you check the couch?")
  end
end
