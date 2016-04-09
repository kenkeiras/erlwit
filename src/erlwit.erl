-module(erlwit).

%% erlwit: erlwit library's entry point.

-export([parse/2]).
-record(outcome,
        {
          intent
         ,confidence
         ,entities=[]
        }).

%% API

parse(Message, Token) ->
    inets:start(),
    ssl:start(),

    case httpc:request(get,
                 {"https://api.wit.ai/message?q=" ++ edoc_lib:escape_uri(Message),
                 [{"Authorization", "Bearer " ++ Token},
                  {"Accept", "application/vnd.wit.20141022+json"}]},
                       [], []) of
        {ok, Result} ->
            ResultElement = element(1, parseResult(element(3, Result))),
            convert_outcomes(
              outcomes_from_result(ResultElement), []);
        {error, Reason} ->
            {error, Reason}
    end.

%% Internals

parseResult(Result) ->
    jiffy:decode(Result).

outcomes_from_result([]) ->
    [];

outcomes_from_result([{<<"outcomes">>, Outcomes} | _ ]) ->
    Outcomes;

outcomes_from_result([_ | T]) ->
    outcomes_from_result(T).

convert_outcomes([], Acc) ->
    Acc;

convert_outcomes([H | T], Acc) ->
    convert_outcomes(T, [convert_outcome(H) | Acc]).

convert_outcome(Outcome) ->
    OutcomeElement = element(1, Outcome),
    #outcome{intent=get_intent(OutcomeElement)
            ,confidence=get_confidence(OutcomeElement)
            ,entities=get_entities(OutcomeElement)}.

get_intent(Element) ->
    get_property(Element, <<"intent">>).

get_confidence(Element) ->
    get_property(Element, <<"confidence">>).

get_entities(Element) ->
    element(1, get_property(Element, <<"entities">>)).

get_property([], _) ->
    none;

get_property([{Property, Value} | _], Property) ->
    Value;

get_property([_H | T], Property) ->
    get_property(T, Property).

%% End of Module.
