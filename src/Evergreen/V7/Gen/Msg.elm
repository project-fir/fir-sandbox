module Evergreen.V7.Gen.Msg exposing (..)

import Evergreen.V7.Pages.Sheet
import Evergreen.V7.Pages.VegaLite


type Msg
    = Sheet Evergreen.V7.Pages.Sheet.Msg
    | VegaLite Evergreen.V7.Pages.VegaLite.Msg
