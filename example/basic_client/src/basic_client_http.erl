-module(basic_client_http).

-export([init/2]).
-export([handle/2]).
-export([terminate/3]).
-export([cookie_name/0]).

-define(COOKIE, <<"basic_client_session">>).

-record(state, {
	session = undefined
}).


init(Req, _Opts) ->
    try extract_args(Req) of
        {ok, Req2, State} -> 
            Req3 = handle(Req2, State),

            {ok, Req3, State}
    catch
        _:_ -> {ok, Req, #state{}}
    end.

handle(Req, #state{session = Session } = State) ->
    %% clear the cookie again, so after a page reload one can retest it.
    Opts = #{
        max_age   => 0, 
        http_only => true,
        path      => <<"/">>
    },
    Req2 = cowboy_req:set_resp_cookie(?COOKIE, <<"deleted">>, Req, Opts),
    Req3 = cowboy_req:set_resp_body(get_body(Session), Req2),
    Req4 = cowboy_req:reply(200, Req3),

    {ok, Req4, State}.

terminate(_Reason, _Req, _State) -> ok.

cookie_name() -> ?COOKIE.


get_body(undefined) ->
    " <!DOCTYPE html>
    <html lang=\"en\">
        <body>
           you are not yet logged in, please do so by following
           <a href=\"/oidc?provider=google\">going without cookie</a>
               </br>
           you can also login
           <a href=\"/oidc?provider=google&use_cookie=true\">with using a cookie</a>
               </br>
           or use the url_extension
           <a href=\"/oidc?provider=google&url_extension=eyJvdGhlcmtleSI6ImltcG9ydGFudCIsInByb3ZpZGVyX2hpbnQiOiJ0ZXN0aW5nIn0\">with extension</a>
        </body>
    </html>";
get_body(_) ->
    "<!DOCTYPE html>
    <html lang=\"en\">
        <body>
           you are logged in
        </body>
    </html>".

extract_args(Req) ->
    Cookies = cowboy_req:parse_cookies(Req),
    Session = case lists:keyfind(?COOKIE, 1, Cookies) of
        false           -> undefined;
        {?COOKIE, Data} -> Data
    end,

    {ok, Req, #state{
        session = Session
    }}.
