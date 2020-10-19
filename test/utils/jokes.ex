defmodule Jokes do
  def joke do
    Jason.encode!(%{
      "icon_url" => "https://assets.chucknorris.host/img/avatar/chuck-norris.png",
      "id" => "sqfcIiJLTne3zoNkaWzDsA",
      "url" => "",
      "value" =>
        "Chuck Norris easily won on 'Iron Chef America' by microwaving 2 ham & cheese Hotpockets. Prior to the show, he advised the judges he would provide them with thier choice of either Hotpockets or a knuckle sandwich."
    })
  end

  def id do
    "sqfcIiJLTne3zoNkaWzDsA"
  end

  def response do
    %{
      "body" =>
        "{\"categories\":[],\"created_at\":\"2020-01-05 13:42:20.841843\",\"icon_url\":\"https://assets.chucknorris.host/img/avatar/chuck-norris.png\",\"id\":\"sqfcIiJLTne3zoNkaWzDsA\",\"updated_at\":\"2020-01-05 13:42:20.841843\",\"url\":\"https://api.chucknorris.io/jokes/sqfcIiJLTne3zoNkaWzDsA\",\"value\":\"Chuck Norris easily won on 'Iron Chef America' by microwaving 2 ham & cheese Hotpockets. Prior to the show, he advised the judges he would provide them with thier choice of either Hotpockets or a knuckle sandwich.\"}",
      "type" => "joke"
    }
  end

  def favorites do
    %{
      "body" => %{
        "joke_ids" => ["sqfcIiJLTne3zoNkaWzDsA"],
        "jokes" => [
          "{\"categories\":[],\"created_at\":\"2020-01-05 13:42:20.841843\",\"icon_url\":\"https://assets.chucknorris.host/img/avatar/chuck-norris.png\",\"id\":\"sqfcIiJLTne3zoNkaWzDsA\",\"updated_at\":\"2020-01-05 13:42:20.841843\",\"url\":\"https://api.chucknorris.io/jokes/sqfcIiJLTne3zoNkaWzDsA\",\"value\":\"Chuck Norris easily won on 'Iron Chef America' by microwaving 2 ham & cheese Hotpockets. Prior to the show, he advised the judges he would provide them with thier choice of either Hotpockets or a knuckle sandwich.\"}"
        ]
      },
      "type" => "favorites"
    }
  end

  def shared_favorites(username) do
    %{
      "body" => %{
        "favorites" => [
          "{\"categories\":[],\"created_at\":\"2020-01-05 13:42:20.841843\",\"icon_url\":\"https://assets.chucknorris.host/img/avatar/chuck-norris.png\",\"id\":\"sqfcIiJLTne3zoNkaWzDsA\",\"updated_at\":\"2020-01-05 13:42:20.841843\",\"url\":\"https://api.chucknorris.io/jokes/sqfcIiJLTne3zoNkaWzDsA\",\"value\":\"Chuck Norris easily won on 'Iron Chef America' by microwaving 2 ham & cheese Hotpockets. Prior to the show, he advised the judges he would provide them with thier choice of either Hotpockets or a knuckle sandwich.\"}"
        ],
        "from" => username
      },
      "type" => "shared_favorites"
    }
  end
end
