defmodule Chuck.UserSupervisor do
  @moduledoc """
  Supervisor to handle creation of dynamic processes to handle new and existing users
  """

  use DynamicSupervisor
  require Logger

  alias Chuck.User

  @username :username

  @doc """
  Start the supervisor
  """
  def start_link([]), do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  @doc false
  @impl true
  def init(args), do: DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [args])

  @doc """
  Each process is a tied to a username
  Get an existing one or create one

  ## Examples
  iex>Chuck.UserSupervisor.get_process("Bill")
  {:ok, "Bill"}
  """
  def get_process(username) do
    if process_exists?(username) do
      {:ok, username}
    else
      username |> create_process
    end
  end

  @doc """
  Determines if a process exists already
  ## Examples
  iex>Chuck.UserSupervisor.process_exists?("Joe")
  false

  iex>Chuck.UserSupervisor.get_process("Ann")
  {:ok, "Ann"}
  iex>Chuck.UserSupervisor.process_exists?("Ann")
  true
  """
  def process_exists?(username) do
    case Registry.lookup(@username, "#{username}") do
      [] -> false
      _ -> true
    end
  end

  @doc """
  Create a new process if it doesn't already exist
  ## Examples
  iex>Chuck.UserSupervisor.create_process("Robert")
  {:ok, "Robert"}

  iex>Chuck.UserSupervisor.create_process("Mike")
  iex>Chuck.UserSupervisor.create_process("Mike")
  {:error, :process_already_exists}
  """
  def create_process(id) do
    spec = %{id: id, start: {User, :start_link, [id]}}

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, _pid} -> {:ok, id}
      {:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      other -> {:error, other}
    end
  end
end
