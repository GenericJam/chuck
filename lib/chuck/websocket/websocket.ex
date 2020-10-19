defmodule Chuck.Websocket do
  @behaviour :cowboy_websocket

  require Logger

  # The state of the User right now
  defstruct username: ""

  @doc """
  Before upgrade

  ## Examples
  iex> Chuck.Websocket.init(Chuck.WebsocketHelpers.request_start_session(), "ignore")
  {:cowboy_websocket, Chuck.WebsocketHelpers.request_start_session(), %Chuck.Websocket{username: "TomBombadil"}}

  iex>{:ok, cowboy_400, %{}} = Chuck.Websocket.init(Chuck.WebsocketHelpers.request_fail_start_session(), "ignore")
  iex>Chuck.WebsocketHelpers.request_equality(Chuck.WebsocketHelpers.cowboy_400, cowboy_400)
  true
  """
  def init(%{path_info: path_info} = request, _state) do
    # path_info is a list of all of the args after the host eg /username/whatever/else
    # Put something in to limit username to sane length and characters...
    cond do
      validate_user(path_info) ->
        username = path_info |> Enum.at(0)
        # Third arg %__MODULE__{username: username} becomes init state
        {:cowboy_websocket, request, %__MODULE__{username: username}}

      true ->
        # Failed to provide proper username
        {:ok, :cowboy_req.reply(400, request), %{}}
    end
  end

  # Just tidier t/f
  defp validate_user(path_info) do
    path_info |> is_list and path_info |> Enum.at(0) |> is_binary and
      path_info |> Enum.at(0) |> String.length() < 32
  end

  @doc """
  After upgrade

  ## Examples
  iex>Chuck.Websocket.websocket_init(%Chuck.Websocket{username: "TomBombadil"})
  {:ok, %Chuck.Websocket{username: "TomBombadil"}}

  iex>Chuck.Websocket.websocket_init(%{})
  {:stop, []}

  """
  def websocket_init(%{username: username} = state) do
    Chuck.UserApplication.get_user(%{username: username, websocket_pid: self()})
    {:ok, state}
  end

  # Something went wrong as it didn't hit a match
  def websocket_init(other) do
    Logger.info(
      "Something went wrong with getting username from request #{other |> inspect}. Closing connection."
    )

    # Kill off this connection as it is no longer valid without a username
    {:stop, []}
  end

  @doc """
  Handle each message
  These are Cowboy methods

  ## Examples
  iex>Chuck.Websocket.websocket_handle({:text, %{"type"=>"favorite", "body" => %{"joke_id" => "0eT4dyWoQAmz2614dyfDFQ"}} |> Jason.encode!()}, %Chuck.Websocket{username: "TomBombadil"})
  {:ok, %Chuck.Websocket{username: "TomBombadil"}}

  iex>Chuck.Websocket.websocket_handle({:text, "not json"}, %Chuck.Websocket{username: "TomBombadil"})
  {:reply, {:text, "Probably not JSON. Ill formed request."}}
  """
  def websocket_handle({:text, raw_json}, %{username: username} = state) do
    Logger.info("From client: #{raw_json |> inspect}")

    case websocket_reply(username, Jason.decode(raw_json)) do
      # In case of error return it
      {:error, message} -> {:reply, message}
      # Otherwise it parsed and is being processed
      :ok -> {:ok, state}
    end
  end

  # Catch all. Monitor for weird garbage coming from the client.
  def websocket_handle(something_else, state) do
    Logger.info(
      "Unexpected from client: #{something_else |> inspect} in state #{state |> inspect}"
    )

    {:ok, state}
  end

  @doc """
  Not a cowboy method. It just catches the next bit and forwards it or gives error message
  """
  def websocket_reply(username, {:ok, message}) do
    # Send to user genserver
    Chuck.UserApplication.user_message(%{username: username, message: message})
    :ok
  end

  # Failed to parse json
  def websocket_reply(_username, _not_json) do
    {:error, {:text, "Probably not JSON. Ill formed request."}}
  end

  @doc """
  These are cowboy methods which catch the replies back from the rest of the application
  """
  # Tell the websocket to close
  def websocket_info(:close, state) do
    Logger.info("Close websocket with state: #{state |> inspect}")
    {:stop, state}
  end

  # Normal message sent from application
  def websocket_info(%{"type" => type} = message, state) when is_binary(type) do
    Logger.debug("Sending to client: #{message |> inspect}")
    {:reply, {:text, Jason.encode!(message)}, state}
  end

  # Catch all. If you get a message here it's likely a bug
  def websocket_info(message, state) do
    Logger.debug(
      "Unexpected message from application: #{message |> inspect} state: #{state |> inspect}"
    )
  end
end
