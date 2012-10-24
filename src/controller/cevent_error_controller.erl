-module(cevent_error_controller, [Req]).
-export([notfound/2]).

notfound('GET', _) ->
    {ok, []}.

