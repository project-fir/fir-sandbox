module Evergreen.V5.Gen.Msg exposing (..)

import Evergreen.V5.Pages.Sheet
import Evergreen.V5.Pages.VegaLite


type Msg
    = Sheet Evergreen.V5.Pages.Sheet.Msg
    | VegaLite Evergreen.V5.Pages.VegaLite.Msg
