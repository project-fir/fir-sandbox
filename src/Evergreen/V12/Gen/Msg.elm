module Evergreen.V12.Gen.Msg exposing (..)

import Evergreen.V12.Pages.Kimball
import Evergreen.V12.Pages.Sheet
import Evergreen.V12.Pages.VegaLite


type Msg
    = Kimball Evergreen.V12.Pages.Kimball.Msg
    | Sheet Evergreen.V12.Pages.Sheet.Msg
    | VegaLite Evergreen.V12.Pages.VegaLite.Msg
