module Config exposing (..)

import Env


apiHost =
    case Env.mode of
        Env.Production ->
            "https://fir-api.robsoko.tech"

        _ ->
            "http://localhost:8000"



-- develop against local dev-fastapi
--"http://localhost:8080"
-- develop against gunicorn server
--"https://fir-api.robsoko.tech"
-- develop against prod
