-module(devices_handler).

-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
  Req = handle(Method, Req0),
	{ok, Req, Opts}.

handle(<<"GET">>, Req) ->
  List = lists:map(fun({_, D}) -> D end, websocket:list()),
  Response = jiffy:encode(List),
  Headers =#{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	},
  cowboy_req:reply(200, Headers, Response, Req);

handle(_, Req) ->
	cowboy_req:reply(405, Req).

