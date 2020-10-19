defmodule Chuck.WebsocketHelpers do
  require Logger
  # This is what a successful request to start a session looks like
  def request_start_session do
    %{
      bindings: %{},
      body_length: 0,
      cert: :undefined,
      has_body: false,
      headers: %{
        "connection" => "Upgrade",
        "host" => "localhost:4000",
        "sec-websocket-extensions" => "permessage-deflate; client_max_window_bits",
        # "sec-websocket-key" => "f6rjEdvJkpkWlAzzLZAS7w==",
        "sec-websocket-version" => "13",
        "upgrade" => "websocket"
      },
      host: "localhost",
      host_info: :undefined,
      method: "GET",
      path: "/jokes/TomBombadil",
      path_info: ["TomBombadil"],
      # peer: {{127, 0, 0, 1}, 59519},
      pid: self(),
      port: 4000,
      qs: "",
      ref: Chuck.Endpoint.HTTP,
      scheme: "http",
      sock: {{127, 0, 0, 1}, 4000},
      streamid: 1,
      version: :"HTTP/1.1"
    }
  end

  # This is requesting a session without providing a username
  def request_fail_start_session do
    %{
      bindings: %{},
      body_length: 0,
      cert: :undefined,
      has_body: false,
      headers: %{
        "connection" => "Upgrade",
        "host" => "localhost:4000",
        "sec-websocket-extensions" => "permessage-deflate; client_max_window_bits",
        "sec-websocket-key" => "f6rjEdvJkpkWlAzzLZAS7w==",
        "sec-websocket-version" => "13",
        "upgrade" => "websocket"
      },
      host: "localhost",
      host_info: :undefined,
      method: "GET",
      path: "/jokes",
      path_info: [],
      peer: {{127, 0, 0, 1}, 59519},
      pid: self(),
      port: 4000,
      qs: "",
      ref: Chuck.Endpoint.HTTP,
      scheme: "http",
      sock: {{127, 0, 0, 1}, 4000},
      streamid: 1,
      version: :"HTTP/1.1"
    }
  end

  def request_equality(
        %{
          bindings: bindings,
          body_length: body_length,
          cert: cert,
          headers: %{
            "connection" => conn,
            "upgrade" => upgrade
          },
          host: host,
          method: method,
          path: path,
          path_info: path_info,
          pid: pid,
          port: port,
          qs: "",
          ref: ref,
          scheme: scheme,
          sock: sock,
          version: version
        },
        %{
          bindings: bindings,
          body_length: body_length,
          cert: cert,
          headers: %{
            "connection" => conn,
            "upgrade" => upgrade
          },
          host: host,
          method: method,
          path: path,
          path_info: path_info,
          pid: pid,
          port: port,
          qs: "",
          ref: ref,
          scheme: scheme,
          sock: sock,
          version: version
        }
      ) do
    true
  end

  def request_equality(req1, req2) do
    Logger.info("req1")
    Logger.info(req1 |> inspect())
    Logger.info("does not equal req2")
    Logger.info(req2 |> inspect())
    false
  end

  # How cowboy says go away
  def cowboy_400 do
    %{
      bindings: %{},
      body_length: 0,
      cert: :undefined,
      has_body: false,
      has_sent_resp: true,
      headers: %{
        "connection" => "Upgrade",
        "host" => "localhost:4000",
        "sec-websocket-extensions" => "permessage-deflate; client_max_window_bits",
        "sec-websocket-key" => "Dmqd1mw8VH2ZmuoFldggSQ==",
        "sec-websocket-version" => "13",
        "upgrade" => "websocket"
      },
      host: "localhost",
      host_info: :undefined,
      method: "GET",
      path: "/jokes",
      path_info: [],
      peer: {{127, 0, 0, 1}, 60004},
      pid: self(),
      port: 4000,
      qs: "",
      ref: Chuck.Endpoint.HTTP,
      scheme: "http",
      sock: {{127, 0, 0, 1}, 4000},
      streamid: 1,
      version: :"HTTP/1.1"
    }
  end
end
