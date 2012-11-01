-module(cevent_index_controller, [Req]).
-compile(export_all).

index('GET', []) ->
    Name = Req:cookie("user_id"),
    Args = [{person, Name} || (Name == "") orelse (Name =/= undefined)],
    {ok, Args}.

logout('GET', []) ->
    Name = Req:cookie("user_id"),
    Args = [{person, Name} || (Name == "") orelse (Name =/= undefined)],
    {ok, Args}.
