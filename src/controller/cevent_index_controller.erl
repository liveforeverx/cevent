-module(cevent_index_controller, [Req]).
-compile(export_all).

index('GET', []) ->
    {ok, auth_lib:partial_cookie(Req)}.

logout('GET', []) ->
    {ok, auth_lib:partial_cookie(Req)}.

about('GET', []) ->
    {ok, auth_lib:partial_cookie(Req)}.

contact('GET', []) ->
    {ok, auth_lib:partial_cookie(Req)}.
