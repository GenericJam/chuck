defmodule Chuck.JokeGenServer do
  @moduledoc """
  This isolates the interactions with the API
  """

  use GenServer

  require Logger

  @joke_api __MODULE__

  @doc """
  Init callback
  """
  def init([]) do
    {:ok, []}
  end

  @doc """
  Start
  """
  def start_link(_) do
    GenServer.start_link(@joke_api, [], name: @joke_api)
  end

  def get(%{message: _, websocket_pid: _} = args_tuple) do
    send_async(args_tuple)
  end

  def share_favorites(%{message: _, username: _, favorites: _} = args_tuple) do
    send_async(args_tuple)
  end

  @doc """
  Translate GenServer.call to send_sync
  """
  def send_sync(args_tuple), do: GenServer.call(@joke_api, args_tuple)

  @doc """
  Translate GenServer.cast to send_async
  """
  def send_async(args_tuple), do: GenServer.cast(@joke_api, args_tuple)

  @doc """
  Call me maybe

  ## Examples
  iex>Chuck.JokeGenServer.handle_call("anything", self(), %{})
  {:reply, "Pocket dial?", %{}}

  """
  # Generic call
  def handle_call(message, from, state) do
    Logger.debug(
      "Unexpected call in JokeGenServer: #{message |> inspect}, #{from |> inspect}, #{
        state |> inspect
      }"
    )

    {:reply, "Pocket dial?", state}
  end

  @doc """
  All cast functions

  ## Examples - just a smoke test really doesn't really test anything other than these won't crash the server
  iex>Chuck.JokeGenServer.handle_cast(%{message: %{"type" => "get", "body" => %{"extension" => "0eT4dyWoQAmz2614dyfDFQ"}}, websocket_pid: self()}, %{})
  {:noreply, %{}}

  iex>Chuck.JokeGenServer.handle_cast(%{message: %{"type" => "share_favorites", "body" => %{"share_with" => "Sue"}}, username: "Zorro", favorites: []}, %{})
  {:noreply, %{}}

  iex>Chuck.JokeGenServer.handle_cast(%{message: %{"type" => "share_favorites", "body" => %{"share_with" => "Sue"}}, username: "Zorro",favorites: []}, %{})
  {:noreply, %{}}
  """
  # Service a single request to the API
  def handle_cast(
        %{
          message: %{"type" => "get", "body" => %{"extension" => extension}} = message,
          websocket_pid: websocket_pid
        },
        state
      ) do
    url = URI.encode("#{Application.get_env(:chuck, :url)}#{extension}")

    response =
      handle_request(
        Mojito.request(
          method: :get,
          url: url,
          # There's a problem with the SSL certs on this site so ignoring them otherwise it fails
          opts: [transport_opts: [verify: :verify_none]]
        )
      )

    send(websocket_pid, %{"type" => "joke", "body" => response})

    {:noreply, state}
  end

  # Get all of the favorites of one user and send them to another
  def handle_cast(
        %{
          message: %{"type" => "share_favorites", "body" => %{"share_with" => other_user}},
          username: username,
          favorites: favorites
        },
        state
      )
      when is_list(favorites) do
    response = get_favorites(favorites)

    # Send it to the other User GenServer which will then get sent to their websocket
    Chuck.UserApplication.user_message(%{
      username: other_user,
      message: %{
        "type" => "shared_favorites",
        "body" => %{"favorites" => response, "from" => username}
      }
    })

    {:noreply, state}
  end

  # Give the user back their own favorites
  def handle_cast(
        %{message: %{"type" => "favorites"}, favorites: favorites, websocket_pid: websocket_pid},
        state
      )
      when is_list(favorites) do
    response = get_favorites(favorites)

    send(websocket_pid, %{
      "type" => "favorites",
      "body" => %{"joke_ids" => favorites, "jokes" => response}
    })

    {:noreply, state}
  end

  # Generic cast
  def handle_cast(message, state) do
    Logger.debug("Unexpected cast in JokeGenServer: #{message |> inspect}, #{state |> inspect}")
    {:noreply, state}
  end

  # Filter on response
  defp handle_request({:ok, %Mojito.Response{body: raw_json, status_code: 200}}) do
    raw_json
  end

  defp handle_request(error) do
    Logger.error("Error trying to access Chuck API #{error |> inspect}")
    # Fail gracefully
    %{}
  end

  # Fetches all of the favorites in the supplied list
  defp get_favorites(favorites_list) when is_list(favorites_list) do
    favorites_list
    |> Enum.map(fn favorite ->
      # The joke id is also the extension
      handle_request(
        Mojito.request(
          method: :get,
          url: URI.encode("#{Application.get_env(:chuck, :url)}#{favorite}"),
          # There's a problem with the SSL certs on this site so ignoring them otherwise it fails
          opts: [transport_opts: [verify: :verify_none]]
        )
      )
    end)
  end
end
