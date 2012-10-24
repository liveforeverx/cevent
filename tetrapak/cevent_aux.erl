-task {"build:lang", "build language files"}.
-task {"build:erlang", "compile Erlang modules using ChicagoBoss"}.
-task {"start:dev", "start ChicagoBoss for development"}.

-define(APP, cevent).

run("start:dev", _) ->
    tpk_file:mkdir(tetrapak:path("log")),
    Config = [{developing_app, ?APP}, {applications, [?APP]}, {db_host, "localhost"},
              {db_port, 1978}, {db_adapter, mock}, {log_dir, "log"}, {server, mochiweb},
              {port, 8001}, {session_adapter, mock}, {session_key, "_boss_session"},
              {session_exp_time, 525600}],
    [application:set_env(boss, ConfOption, ConfValue) || {ConfOption, ConfValue} <- Config],
    tetrapak:require("tetrapak:startapp"),
    reloader:start(),
    tetrapak:require("shell");

run("build:erlang", _) ->
    OutDir = tetrapak:path("ebin"),
    tpk_file:mkdir(OutDir),

    %% load the boss reload module
    reloader:start(),
    %% put boss into devel mode
    application:set_env(boss, developing_app, ?APP),

    TranslatorPid = boss_translator:start([{application, ?APP}]),
    case catch boss_load:load_all_modules(?APP, TranslatorPid, OutDir) of
        {ok, AllModules} ->
            [output(replace_atom(Name), Modules) || {Name, Modules} <- AllModules],
            done;
        {'EXIT', Error} ->
            io:format("failed to load: ~p~n", [Error]),
            tetrapak:fail()
    end;

run("build:lang", _) ->
    tetrapak:require("build:erlang"),
    boss_lang:update_po(tetrapak:get("config:appfile:name")),
    done.

replace_atom(Atom) ->
    String = atom_to_list(Atom),
    replace(String, "_", " ").

replace(String, [From], [To]) ->
    lists:reverse(lists:foldl(fun(FromA, Acc) when (From == FromA) -> [To | Acc];
                                 (A, Acc)  -> [A | Acc]
                              end, "", String)).

%output(_Name, [])                           -> ok;
output(Name, Modules) when is_list(Modules) -> io:format("Compiled ~b ~s~n", [length(Modules), Name]).
