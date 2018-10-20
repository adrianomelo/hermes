-module(hermes_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
  websocket:start(),
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/ping", ping_handler, []},
      {"/websocket", ws_handler, []},
      {"/devices", devices_handler, []},
      {"/devices/:id/ack", devices_handler, [ack]}
    ]}
  ]),
  {ok, _} = cowboy:start_clear(
      hermes_http_listener,
      [{port, 8080}],
      #{env => #{dispatch => Dispatch}}
  ),
  hermes_sup:start_link().

stop(_State) ->
    ok.

