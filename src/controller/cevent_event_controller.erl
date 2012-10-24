-module(cevent_event_controller, [Req, SessionId]).
-compile(export_all).

before_(_) ->
    auth_lib:require_login(Req).

index('GET', [], Person) ->
    {ok, []}.

create('GET', [], Person) ->
    {ok, []};

create('POST', [], Person) ->
    Firstname = Req:post_param("name"),
    Lastname = Req:post_param("type"),
    City = Req:post_param("city"),
    State = Req:post_param("description"),
    CreationTime = erlang:localtime(),
    ModificationTime = erlang:localtime(),
    NewAddress = event:new(id, Firstname, Lastname, City, State, CreationTime, ModificationTime),
    case NewAddress:save() of
        {ok, SavedAddress}->
            {redirect, [{action, "created"}]};
        {error, Reason}->
            Reason
    end.

created('GET', [], Person) ->
    {ok, []}.

category('GET', [], Person) ->
    {ok, []}.

