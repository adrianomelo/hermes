-module(devices_handler).

-export([init/2]).

init(Req0, Opts) ->
  io:fwrite("~p~n~p~n", [Req0, Opts]),
	Method = cowboy_req:method(Req0),
  Req = handle(Method, Req0, Opts),
	{ok, Req, Opts}.

handle(<<"GET">>, Req, [ack]) ->
  Process = cowboy_req:binding(id, Req, nil),
  Pid = list_to_pid(binary_to_list(Process)),
  Pid ! {react}, 
  Response = jiffy:encode(websocket:list()),
  Headers =#{
		<<"content-type">> => <<"application/json; charset=utf-8">>,
    <<"access-control-allow-methods">> => <<"GET, OPTIONS">>,
    <<"access-control-allow-origin">> => <<"*">>
	},
  cowboy_req:reply(200, Headers, Response, Req);

handle(<<"GET">>, Req, _) ->
  Response = jiffy:encode(websocket:list()),
  Headers =#{
		<<"content-type">> => <<"application/json; charset=utf-8">>,
    <<"access-control-allow-methods">> => <<"GET, OPTIONS">>,
    <<"access-control-allow-origin">> => <<"*">>
	},
  cowboy_req:reply(200, Headers, Response, Req);

handle(_, Req, _) ->
	cowboy_req:reply(405, Req).

