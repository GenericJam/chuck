# Chuck

## API for interacting with the [Chuck Norris API](https://api.chucknorris.io/)

### If for some reason you want to build this yourself

`git clone https://github.com/GenericJam/chuck.git`

`cd chuck`

`mix deps.get`

`iex -S mix`


### Interact with it like this
Go get [wscat](https://github.com/websockets/wscat) or some sort of websocket client

Interact with JSON. The pattern is `{"type":"whatever","body":{"key":"value"}}` some of which are valid without a `body`.

Start a session like so. Your username is your id.

`$ wscat -c ws://localhost:4000/jokes/BillTheThrill`

Get a random joke

`$ >{"type":"get"}`

Get a joke by id

`$ >{"type":"get","body":{"extension":"cmuUd1ZDRKS_qltTyAoH2w"}}`

Get jokes by search query or any other domain extension the API can handle

`$ >{"type":"get","body":{"extension":"search?query=skateboard"}}`

Favorite your jokes like this

`$ >{"type":"favorite","body":{"joke_id":"mHBDmiiqRwOv2qOfx0gu6Q"}}`

Get all your favorite jokes like this

`$ >{"type":"favorites"}`

Start another terminal and start another session to make a second user

`$ wscat -c ws://localhost:4000/jokes/DropKick`

Send all your favorite jokes to another user like this

`$ >{"type":"share_favorites","body":{"share_with":"DropKick"}}`
