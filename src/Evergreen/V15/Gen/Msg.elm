module Evergreen.V15.Gen.Msg exposing (..)

import Evergreen.V15.Pages.Kimball
import Evergreen.V15.Pages.Sheet
import Evergreen.V15.Pages.VegaLite


type Msg
    = Kimball Evergreen.V15.Pages.Kimball.Msg
    | Sheet Evergreen.V15.Pages.Sheet.Msg
    | VegaLite Evergreen.V15.Pages.VegaLite.Msg
