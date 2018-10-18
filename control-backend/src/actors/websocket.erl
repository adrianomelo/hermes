-module(websocket).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export(
   [ start/0
   , empty/0
   , add/2
   , remove/1
   , send/1
   , list/0
   , update/2
   ]).

-ifdef(TEST).
-compile(export_all).
-endif.

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Public API        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

add(Pid, Extra) ->
  gen_server:cast(?MODULE, {add, Pid, Extra}).

update(Pid, Extra) ->
  gen_server:cast(?MODULE, {update, Pid, Extra}).

remove(Pid) ->
  gen_server:cast(?MODULE, {remove, Pid}).

send(Msg) ->
  gen_server:cast(?MODULE, {send, Msg}).

list() ->
  gen_server:call(?MODULE, {list}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   gen_server handlers   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

init([]) ->
  {ok, empty()}.

handle_call({list}, _, State) ->
  {reply, State, State};

handle_call(_, _, State) ->
  {reply, error, State}.

handle_cast({remove, Pid}, State) ->
  NewState = remove(State, Pid),
  {noreply, NewState};

handle_cast({add, Pid, Extra}, State) ->
  NewState = lists:append(State, [{Pid, Extra}]),
  {noreply, NewState};

handle_cast({update, Pid, Extra}, State) ->
  NewState = lists:map(
    fun({P, E}) ->
      if
        P == Pid -> {Pid, Extra};
        true -> {P, E}
      end
    end,
    State
  ),
  {noreply, NewState};

handle_cast({send, Msg}, State) ->
  lists:foreach(fun ({Pid, _}) -> Pid ! Msg end, State),
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

remove(List, Pid) ->
  lists:filter(fun({Pd,_}) -> Pd /= Pid end, List).

