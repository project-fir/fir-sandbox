module Config exposing (apiHost)

import Env


type LocalDevModes
    = PointToProduction
    | PointToLocalGunicorn
    | PointToLocalDevFastApi


localDevMode =
    PointToLocalDevFastApi


apiHost =
    case Env.mode of
        Env.Production ->
            "https://fir-api.robsoko.tech"

        _ ->
            case localDevMode of
                PointToLocalDevFastApi ->
                    "http://localhost:8000"

                PointToLocalGunicorn ->
                    "http://localhost:8080"

                PointToProduction ->
                    "https://fir-api.robsoko.tech"
