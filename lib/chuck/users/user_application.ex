defmodule Chuck.UserApplication do
  @moduledoc """
  All the User requests are routed through here
  """

  use Application

  require Logger

  alias Chuck.UserSupervisor
  alias Chuck.User

  @username :username

  # Make Elixir compiler happy
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start(_args) do
    # Children to be supervised
    children = [
      {Registry, keys: :unique, name: @username},
      {UserSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Chuck.ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Connect with existing or create user
  Called when websocket is initiated
  """
  def get_user(%{username: username, websocket_pid: websocket_pid}) do
    Logger.info("get_user #{%{username: username, websocket_pid: websocket_pid} |> inspect}")
    UserSupervisor.get_process(username)
    User.send_async(username, {:init_socket, websocket_pid})
  end

  @doc """
  Send User GenServer a message
  """
  def user_message(%{username: username, message: message}) do
    Logger.info("user_message #{message |> inspect}")
    User.send_async(username, message)
  end

  # @doc """
  # Send User client a message
  # """
  # def receive_message(%{username: username, message: message}) do
  #   Logger.info("user_message #{message |> inspect}")
  #   User.send_async(username, message)
  # end

  def get_state(username) do
    # UserSupervisor.get_process(username)
    Logger.info("State of #{username}")
    User.send_sync(username, {:get_state}) |> inspect() |> Logger.info()
  end
end
