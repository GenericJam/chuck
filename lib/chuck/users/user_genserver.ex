defmodule Chuck.User do
  @moduledoc """
  This mirrors a user who is connected to the application
  """

  use GenServer

  require Logger

  @username :username

  # The state of the User right now
  defstruct username: "",
            websocket_pid: nil,
            favorites: []

  @doc """
  Init callback
  """
  def init([username]) do
    {:ok, %__MODULE__{username: username}}
  end

  @doc """
  Start a User
  """
  def start_link(_, username) do
    GenServer.start_link(__MODULE__, [username], name: via_username(username))
  end

  @doc """
  Translate GenServer.call to send_sync
  """
  def send_sync(username, args_tuple), do: GenServer.call(via_username(username), args_tuple)

  @doc """
  Translate GenServer.cast to send_async
  """
  def send_async(username, args_tuple), do: GenServer.cast(via_username(username), args_tuple)

  @doc """
  Call me maybe
  """
  def handle_call({:get_state}, from, state) do
    {:reply, state, state}
  end

  # Generic call
  def handle_call(message, from, state) do
    Logger.debug(
      "Unexpected call in User: #{message |> inspect}, #{from |> inspect}, #{state |> inspect}"
    )

    {:reply, "Yo", state}
  end

  @doc """
  All cast functions
  """
  def handle_cast({:init_socket, websocket_pid}, state) do
    {:noreply, %__MODULE__{state | websocket_pid: websocket_pid}}
  end

  # Get all favorites
  def handle_cast(
        %{"type" => "favorites"} = message,
        %{favorites: favorites, websocket_pid: websocket_pid} = state
      ) do
    Chuck.JokeGenServer.get(%{
      message: message,
      favorites: favorites,
      websocket_pid: websocket_pid
    })

    {:noreply, state}
  end

  # Add a favorite
  def handle_cast(
        %{"type" => "favorite", "body" => %{"joke_id" => joke_id}},
        %{favorites: favorites} = state
      ) do
    {:noreply, %__MODULE__{state | favorites: [joke_id | favorites]}}
  end

  # Get a specified response from joke API with extension
  def handle_cast(
        %{"type" => "get", "body" => %{"extension" => _}} = message,
        %{websocket_pid: websocket_pid} = state
      ) do
    Chuck.JokeGenServer.get(%{message: message, websocket_pid: websocket_pid})
    {:noreply, state}
  end

  # Get a random joke from API with no args
  def handle_cast(%{"type" => "get"} = message, %{websocket_pid: websocket_pid} = state) do
    Chuck.JokeGenServer.get(%{
      message: %{"type" => "get", "body" => %{"extension" => "random"}},
      websocket_pid: websocket_pid
    })

    {:noreply, state}
  end

  # Share favorite jokes with other user
  def handle_cast(
        %{"type" => "share_favorites", "body" => %{"share_with" => other_user}} = message,
        %{websocket_pid: websocket_pid, favorites: favorites, username: username} = state
      ) do
    Chuck.JokeGenServer.share_favorites(%{
      message: message,
      username: username,
      favorites: favorites
    })

    {:noreply, state}
  end

  # Receive favorite jokes from other user
  def handle_cast(
        %{"type" => "shared_favorites", "body" => %{"favorites" => response, "from" => username}} =
          message,
        %{websocket_pid: websocket_pid} = state
      ) do
    send(websocket_pid, message)
    {:noreply, state}
  end

  # Generic cast
  def handle_cast(message, state) do
    Logger.debug("Unexpected cast in User: #{message |> inspect}, #{state |> inspect}")

    {:noreply, state}
  end

  # Generic info
  def handle_info(message, state) do
    Logger.debug("Unexpected info in User: #{message |> inspect}, #{state |> inspect}")

    {:noreply, state}
  end

  # Registry lookup handler
  defp via_username(username), do: {:via, Registry, {@username, "#{username}"}}

  def whereis(username) do
    case Registry.lookup(@username, "#{username}") do
      [{pid, _}] -> pid
      [] -> nil
    end
  end
end
