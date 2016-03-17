-module(erlwit).

%% erlwit: erlwit library's entry point.

-export([parse/2]).


%% API

parse(Message, Token) ->
    inets:start(),
    ssl:start(),

    case httpc:request(get,
                 {"https://api.wit.ai/message?q=" ++ Message,
                 [{"Authorization", "Bearer " ++ Token},
                  {"Accept", "application/vnd.wit.20141022+json"}]},
                       [], []) of
        {ok, Result} ->
            parseResult(element(3, Result));
        {error, Reason} ->
            {error, Reason}
    end.

%% Internals

parseResult(Result) ->
    jiffy:decode(Result).

%% End of Module.
