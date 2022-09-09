module Evergreen.V6.Gen.Msg exposing (..)

import Evergreen.V6.Pages.Sheet
import Evergreen.V6.Pages.VegaLite


type Msg
    = Sheet Evergreen.V6.Pages.Sheet.Msg
    | VegaLite Evergreen.V6.Pages.VegaLite.Msg
