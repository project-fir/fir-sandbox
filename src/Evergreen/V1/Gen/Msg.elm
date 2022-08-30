module Evergreen.V1.Gen.Msg exposing (..)

import Evergreen.V1.Pages.Sheet
import Evergreen.V1.Pages.VegaLite


type Msg
    = Sheet Evergreen.V1.Pages.Sheet.Msg
    | VegaLite Evergreen.V1.Pages.VegaLite.Msg
