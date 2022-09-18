module Evergreen.V12.Shared exposing (..)

import Time


type alias Model =
    { zone : Time.Zone
    }


type Msg
    = SetTimeZoneToLocale Time.Zone
