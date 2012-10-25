-module(cevent_user_controller, [Req, SessionId]).
-compile(export_all).

before_(_) ->
    auth_lib:check_user(Req).

login('GET', [], Person)->
     case Person == undefined of
        false ->
            {redirect, "/user/loggedin/"};
        true ->
            {ok, [{redirect, Req:header(referer)},{ip, Req:peer_ip()},{person,Person}]}
     end;
login('POST', [], Person) ->
    Name = Req:post_param("name"),
    case amazon_lib_sdb:get(Name) of
        [{attributes, Attrs}, _] when Attrs =/= [] ->
            case auth_lib:check_password(inl("name", Attrs), inl("passhash", Attrs), Req:post_param("password")) of
                true ->
                    {redirect, "/user/loggedin/" ++ Name ++ "/", auth_lib:login_cookies(inl("name", Attrs))};
                           % {redirect, proplists:get_value("redirect", Req:post_params(), "/"), auth_lib:login_cookies(inl("name", Attrs))};
                    false ->
                        {ok, [{error, "Bad name/password combination"}]}
            end;
        _ ->
            {ok, [{error, "No Person named " ++ Name}]}
    end.

loggedin('GET', [Name], Person) ->
    {ok, [{name, Name}]};

loggedin('GET', [], Person) ->
    {ok, to_output(Person)};

loggedin('POST', _, Person) ->
    {redirect, "/user/login/",
        [ mochiweb_cookies:cookie("user_id", "", [{path, "/"}]),
          mochiweb_cookies:cookie("session_id", "", [{path, "/"}]) ]}.


registered('GET', [], Person) ->
    {ok, []}.

register('GET', [], Person) ->
     case Person == undefined of
        false ->
            {redirect, "/user/loggedin/"};
        true ->
            {ok, [{ip, Req:peer_ip()}]}
     end;
register('POST', [], Person) ->
    Name = to_list(Req:post_param("name")),
    case Name =/= "" of
        true ->
            case amazon_lib_sdb:get(Name) of
                [{attributes,[]}, _] ->
                    Attrs = [{"name", to_list(Req:post_param("name"))},
                             {"passhash", auth_lib:hash_for(Req:post_param("name"), Req:post_param("password"))},
                             {"notes", to_list(Req:post_param("notes"))}],
                    amazon_lib_sdb:put(Name, Attrs),
                    {redirect, "/user/registered/"};
                _ ->
                    {ok, [{error, "Person with name " ++ Name ++ " already exists"}]}
            end;
        false ->
            {ok, [{error, "Person cann't have no name"}]}
    end.

to_list(Bin) when is_binary(Bin) -> binary_to_list(Bin);
to_list(List) -> List.

to_atom(List) when is_list(List) -> list_to_atom(List).

inl(Key, List) -> proplists:get_value(Key, List).

to_output(List) -> [{to_atom(K), V} || {K, V} <- List].
