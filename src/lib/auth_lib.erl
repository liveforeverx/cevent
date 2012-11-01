-module(auth_lib).
-compile(export_all).
-define(SECRET_STRING, "Don't tell anybody about it").

%User's global functions that you can use anywhere just call auth_lib:[func_name]
hash_password(Password, Salt) ->
    case length(Password) > 0 of
        true ->
            mochihex:to_hex(erlang:md5(Salt ++ Password));
        false ->
            ""
    end.

hash_for(Name, Password) ->
    Salt = mochihex:to_hex(erlang:md5(Name)),
    hash_password(Password, Salt).

require_login(Req) ->
    case check_user(Req) of
        {ok, undefined} ->
            {redirect, "/user/login"};
        {ok, Person} ->
            {ok, Person}
     end.

check_user(Req) ->
    case Req:cookie("user_id") of
        undefined ->
            {ok, undefined};
        Id ->
            case Id == "" of
                true ->
                    {ok, undefined};
                false ->
                    case amazon_lib_sdb:get(Id) of
                        [{_, Attrs}, _] when Attrs =/= [] ->
                            case session_identifier(Id) =:= Req:cookie("session_id") of
                                false ->
                                    {ok, undefined};
                                true ->
                                    {ok, Attrs}
                            end;
                        _ ->
                            {ok, undefined}
                    end
            end
     end.

session_identifier(Id) ->
    mochihex:to_hex(erlang:md5(?SECRET_STRING ++ Id)).

check_password(Name, PwdHash, Password) ->
    Salt = mochihex:to_hex(erlang:md5(Name)),
    hash_password(Password, Salt) =:= PwdHash.

login_cookies(Id) ->
    [mochiweb_cookies:cookie("user_id", Id, [{path, "/"}, {max_age, 10}]),
     mochiweb_cookies:cookie("session_id", session_identifier(Id), [{path, "/"},
                                                                    {secure, true}]) ].

partial_cookie(Req) ->
    Name = Req:cookie("user_id"),
    [{person, Name} || (Name == "") orelse (Name =/= undefined)].
