module Config exposing (apiHost)

import Env


type LocalDevModes
    = PointToProduction
    | PointToLocalGunicorn
    | PointToLocalDevFastApi


pointTo =
    PointToProduction


apiHost =
    case pointTo of
        PointToLocalDevFastApi ->
            "http://localhost:8889"

        PointToLocalGunicorn ->
            "http://localhost:8080"

        PointToProduction ->
            "https://fir-api.robsoko.tech"
