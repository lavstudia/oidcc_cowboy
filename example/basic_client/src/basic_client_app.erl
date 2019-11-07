-module(basic_client_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).


start(_, _) ->
    ConfigEndpoint = <<"https://accounts.google.com/.well-known/openid-configuration">>,
    LocalEndpoint  = <<"http://localhost:8080/oidc">>,
    Config = #{
        id            => <<"google">>,
        client_id     => <<"214039446529-d6hkqloinrgbdhfh8p2ghrfj1rupnttm.apps.googleusercontent.com">>,
        client_secret => <<"71wvXT4ZnsCuJy4t8oojwzQG">>
    },
    oidcc:add_openid_provider(ConfigEndpoint, LocalEndpoint, Config),
    basic_client:init(),

    Dispatch = cowboy_router:compile([{'_', [
        {"/",            basic_client_http, []},
        {"/oidc",        oidcc_cowboy,      []},
        {"/oidc/return", oidcc_cowboy,      []}
    ]}]),
    {ok, _} = cowboy:start_clear(http_listener
        		       , [ {port, 8080} ]
        		       , #{
                            env => #{
                                dispatch => Dispatch
                            }
                        }
        		       ),

    basic_client_sup:start_link().

stop(_) -> ok = cowboy:stop_listener(http_listener).
