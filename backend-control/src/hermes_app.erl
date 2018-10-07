-module(hermes_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/ping", ping_handler, []},
      {"/websocket", ws_handler, []}
    ]}
  ]),
  {ok, _} = cowboy:start_clear(
      hermes_http_listener,
      [{port, 8888}],
      #{env => #{dispatch => Dispatch}}
  ),
  hermes_sup:start_link().

stop(_State) ->
    ok.

