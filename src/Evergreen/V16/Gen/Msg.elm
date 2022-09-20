module Evergreen.V16.Gen.Msg exposing (..)

import Evergreen.V16.Pages.Kimball
import Evergreen.V16.Pages.Sheet
import Evergreen.V16.Pages.VegaLite


type Msg
    = Kimball Evergreen.V16.Pages.Kimball.Msg
    | Sheet Evergreen.V16.Pages.Sheet.Msg
    | VegaLite Evergreen.V16.Pages.VegaLite.Msg
