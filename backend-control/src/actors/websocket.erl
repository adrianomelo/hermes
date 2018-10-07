-module(websocket).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start/0, empty/0, add/1, add/2, remove/1, remove/2, send/1]).

-ifdef(TEST).
-compile(export_all).
-endif.

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Public API        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

add(Pid) ->
  gen_server:cast(?MODULE, {add, Pid}).

remove(Pid) ->
  gen_server:cast(?MODULE, {remove, Pid}).

send(Msg) ->
  gen_server:cast(?MODULE, {send, Msg}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   gen_server handlers   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

init([]) ->
  {ok, empty()}.

handle_call(_, _, State) ->
  {reply, error, State}.

handle_cast({remove, Pid}, State) ->
  NewState = remove(State, Pid),
  {noreply, NewState};

handle_cast({add, Pid}, State) ->
  NewState = add(State, Pid),
  {noreply, NewState};

handle_cast({send, Msg}, State) ->
  lists:foreach(fun (Pid) -> Pid ! Msg end, State),
  {noreply, State};

handle_cast(_, State) ->
  {noreply, State}.

handle_info(_, State) ->
  {noreply, State}.

terminate(_, _) ->
  ok.

code_change(_, State, _) ->
  {ok, State}.

%%%%%%%%%%%%%%%%%%%
% Local functions %
%%%%%%%%%%%%%%%%%%%

empty() ->
  [].

add(List, Pid) ->
  lists:append(List, [Pid]).

remove(List, Pid) ->
  lists:filter(fun(Pd) -> Pd /= Pid end, List).

