defmodule ChuckTest do
  use ExUnit.Case
  doctest Chuck
  doctest Chuck.Websocket
  doctest Chuck.UserSupervisor
  doctest Chuck.User
  doctest Chuck.JokeGenServer

  require Logger

  @doc """
  Should probably isolate these calls to the API because it fails some of the time just because the API is a bit flaky but... meh.
  """
  test "Able to create User and get joke" do
    user_one = "PorkchopMcMonkeypants"
    # Create a User and pretend to be the websocket
    Chuck.UserApplication.get_user(%{username: user_one, websocket_pid: self()})

    Chuck.UserApplication.user_message(%{
      username: user_one,
      message: %{"type" => "get", "body" => %{"extension" => Jokes.id()}}
    })

    receive do
      joke ->
        assert joke == Jokes.response()
    after
      5_000 ->
        assert false
    end
  end

  test "Able to create User, favorite joke and receive favorite jokes" do
    user_one = "Johnny5"
    # Create a User and pretend to be the websocket
    Chuck.UserApplication.get_user(%{username: user_one, websocket_pid: self()})

    Chuck.UserApplication.user_message(%{
      username: user_one,
      message: %{"type" => "favorite", "body" => %{"joke_id" => Jokes.id()}}
    })

    Chuck.UserApplication.user_message(%{
      username: user_one,
      message: %{"type" => "favorites"}
    })

    receive do
      favorites ->
        assert favorites == Jokes.favorites()
    after
      5_000 ->
        assert false
    end
  end

  test "Able to create Users and send favorite jokes" do
    user_one = "Cagney"
    user_two = "Lacey"
    # Create a User and pretend to be the websocket
    Chuck.UserApplication.get_user(%{username: user_one, websocket_pid: self()})
    # Create another User and also pretend to be the other websocket
    Chuck.UserApplication.get_user(%{username: user_two, websocket_pid: self()})

    Chuck.UserApplication.user_message(%{
      username: user_one,
      message: %{"type" => "favorite", "body" => %{"joke_id" => Jokes.id()}}
    })

    Chuck.UserApplication.user_message(%{
      username: user_one,
      message: %{"type" => "share_favorites", "body" => %{"share_with" => user_two}}
    })

    receive do
      favorites ->
        assert favorites == Jokes.shared_favorites(user_one)
    after
      5_000 ->
        assert false
    end
  end
end
