-module(ws_handler).

-export([ init/2
        , websocket_init/1
        , websocket_handle/2
        , websocket_info/2
        , terminate/3
        ]).


init(Req, _State) ->
  io:fwrite("init~p~n", [Req]),
  Host = maps:get(host, Req),
  {cowboy_websocket, Req, empty(Host)}.

websocket_init(State) ->
  io:fwrite("websocket_init~n"),
  websocket:add(self(), State),
  erlang:start_timer(1000, self(), ping),
  {ok, State}.

websocket_handle(Frame = {text, Text}, State) ->
  NewState = handle_msg(Text, State),
  websocket:update(self(), State),
  {reply, Frame, NewState};
websocket_handle(_, State) ->
  {ok, State}.

websocket_info({timeout, _Ref, _Msg}, State) ->
	erlang:start_timer(1000, self(), ping),
	{reply, {text, simple_echo_msg()}, State};
websocket_info({json, Json}, State) ->
  {reply, {text, jiffy:encode(Json)}, State};
websocket_info(Msg, State) ->
  io:fwrite("received ~p~n", [Msg]),
  {ok, State}.

terminate(_Reason, _PartialReq, _State) ->
  websocket:remove(self()),
  io:fwrite("terminate\n"),
  ok.

%%%%%%%%%%%%%
%  private  %
%%%%%%%%%%%%%

empty(Host) ->
  #{
    latency => 0,
    host => Host
  }.

simple_echo_msg() ->
  Now = integer_to_list(get_now()),
  lists:concat(["E", Now]).

get_now() ->
  Now = erlang:system_time(),
  erlang:convert_time_unit(Now, native, millisecond).

handle_msg(<<"e", Time/binary>>, State) ->
  Previous = binary_to_integer(Time),
  Current = get_now(),
  Latency = Current - Previous,
  maps:put(latency, Latency, State);
handle_msg(Unknown, State) ->
  io:fwrite("Unknown message: ~p~n", [Unknown]),
  State.

