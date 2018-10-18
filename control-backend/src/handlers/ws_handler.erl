-module(ws_handler).

-export([ init/2
        , websocket_init/1
        , websocket_handle/2
        , websocket_info/2
        , terminate/3
        , handle/1
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
  NewState = handle_msg(jiffy:decode(Text, [return_maps]), State),
  websocket:update(self(), State),
  {reply, Frame, NewState};
websocket_handle(_, State) ->
  {ok, State}.

websocket_info({timeout, _Ref, _Msg}, State) ->
	erlang:start_timer(1000, self(), ping),
	{reply, {text, jiffy:encode(get_echo_msg())}, State};
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

get_echo_msg() ->
  #{type => <<"ECHO">>, time => get_now()}.

get_now() ->
  Now = erlang:system_time(),
  erlang:convert_time_unit(Now, native, millisecond).

handle_msg(#{ <<"type">> := <<"ECHO_BACK">>, <<"time">> := Time}, State) ->
  Current = get_now(),
  Latency = Current - Time,
  maps:put(latency, Latency, State);
handle_msg(_, State) ->
  State.

handle(#{ <<"type">> := <<"ECHO_BACK">>, <<"time">> := Time}) ->
  CurrentTime = get_now(),
  io:fwrite("time: ~w~n", [CurrentTime - Time]);
handle(#{ <<"type">> := Type }) ->
  io:fwrite("type ~s~n", [Type]);
handle(_) ->
  io:fwrite("No handler\n").
