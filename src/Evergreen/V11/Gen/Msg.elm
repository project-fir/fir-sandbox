module Evergreen.V11.Gen.Msg exposing (..)

import Evergreen.V11.Pages.Kimball
import Evergreen.V11.Pages.Sheet
import Evergreen.V11.Pages.VegaLite


type Msg
    = Kimball Evergreen.V11.Pages.Kimball.Msg
    | Sheet Evergreen.V11.Pages.Sheet.Msg
    | VegaLite Evergreen.V11.Pages.VegaLite.Msg
