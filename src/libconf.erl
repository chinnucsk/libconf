%% -----------------------------------------------------------------------------
%%
%% Copyright (c) 2011 Tim Watson (watson.timothy@gmail.com)
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.
%% -----------------------------------------------------------------------------
-module(libconf).

-include("libconf.hrl").
-export([abort/1, abort/2]).
-export([configure/3, printable/1]).

configure(Args, AvailableOpts, Rules) ->
    log:reset(),
    Options = opt:parse_args(Args, AvailableOpts),
    put(verbose, proplists:get_value(verbose, Options)),
    case lists:keymember(help, 1, Options) of
        true ->
            opt:help(AvailableOpts), halt(0);
        false ->
            log:verbose("~s~n", [printable(Options)]),
            Env = env:inspect(Options),
            log:verbose("~s~n", [printable(Env)]),
            apply_config(Env, Rules, Options)
    end.

apply_config(Env, Rules, Options) ->
    Checks = proplists:get_value(checks, Rules, []),
    [ check:check(Check, Env, Options) || Check <- Checks ].

%% Utilities

printable(Term) ->
    erl_prettypr:format(erl_parse:abstract(Term))  ++ ".".

abort(Msg) ->
    abort(Msg, []).

abort(Msg, Args) ->
    log:out(Msg, Args), halt(1).
