-module(ws_handler).

-export([ init/2
        , websocket_init/1
        , websocket_handle/2
        , websocket_info/2
        , terminate/3
        , handle/1
        ]).

handle(#{ <<"type">> := <<"ECHO_BACK">>, <<"time">> := Time}) ->
  CurrentTime = get_now(),
  io:fwrite("time: ~w~n", [CurrentTime - Time]);
handle(#{ <<"type">> := Type }) ->
  io:fwrite("type ~s~n", [Type]);
handle(_) ->
  io:fwrite("No handler\n").

init(Req, Opts) ->
  io:fwrite("init~p~n", [Req]),
  {cowboy_websocket, Req, Opts}.

websocket_init(State) ->
  io:fwrite("websocket_init~n"),
  erlang:start_timer(1000, self(), ping),
  {ok, State}.

websocket_handle(Frame = {text, Text}, State) ->
  handle(jiffy:decode(Text, [return_maps])),
  {reply, Frame, State};
websocket_handle(_, State) ->
  {ok, State}.

websocket_info({timeout, _Ref, _Msg}, State) ->
	erlang:start_timer(1000, self(), ping),
	{reply, {text, jiffy:encode(get_echo_msg())}, State};
websocket_info(_, State) ->
  {ok, State}.

terminate(_Reason, _PartialReq, _State) ->
  io:fwrite("terminate\n"),
  ok.

% Private functions

get_echo_msg() ->
  #{type => <<"ECHO">>, time => get_now()}.

get_now() ->
  Now = erlang:system_time(),
  erlang:convert_time_unit(Now, native, millisecond).

