module Evergreen.V10.Gen.Msg exposing (..)

import Evergreen.V10.Pages.Kimball
import Evergreen.V10.Pages.Sheet
import Evergreen.V10.Pages.VegaLite


type Msg
    = Kimball Evergreen.V10.Pages.Kimball.Msg
    | Sheet Evergreen.V10.Pages.Sheet.Msg
    | VegaLite Evergreen.V10.Pages.VegaLite.Msg
