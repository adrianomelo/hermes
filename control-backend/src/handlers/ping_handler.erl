-module(ping_handler).

-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
  Req = ping(Method, Req0),
	{ok, Req, Opts}.

ping(<<"GET">>, Req) ->
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain; charset=utf-8">>
	}, <<"pong">>, Req);

ping(_, Req) ->
	cowboy_req:reply(405, Req).

