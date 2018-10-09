-module(ws_handler).

-export([ init/2
        , websocket_init/1
        , websocket_handle/2
        , websocket_info/2
        , terminate/3
        ]).

init(Req, Opts) ->
  io:fwrite("init\n"),
  {cowboy_websocket, Req, Opts}.

websocket_init(State) ->
  io:fwrite("websocket_init\n"),
  {ok, State}.

websocket_handle(Frame = {text, Msg}, State) ->
  io:fwrite(<<"websocket_handle: ", Msg/binary, "\n">>),
  {reply, Frame, State};
websocket_handle(_, State) ->
  {ok, State}.

websocket_info(_, State) ->
  io:fwrite("websocket_info\n"),
  {ok, State}.

terminate(_Reason, _PartialReq, _State) ->
  io:fwrite("terminate\n"),
  ok.

