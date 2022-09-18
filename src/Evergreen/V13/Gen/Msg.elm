module Evergreen.V13.Gen.Msg exposing (..)

import Evergreen.V13.Pages.Kimball
import Evergreen.V13.Pages.Sheet
import Evergreen.V13.Pages.VegaLite


type Msg
    = Kimball Evergreen.V13.Pages.Kimball.Msg
    | Sheet Evergreen.V13.Pages.Sheet.Msg
    | VegaLite Evergreen.V13.Pages.VegaLite.Msg
