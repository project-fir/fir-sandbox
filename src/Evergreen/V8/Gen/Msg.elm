module Evergreen.V8.Gen.Msg exposing (..)

import Evergreen.V8.Pages.Kimball
import Evergreen.V8.Pages.Sheet
import Evergreen.V8.Pages.VegaLite


type Msg
    = Kimball Evergreen.V8.Pages.Kimball.Msg
    | Sheet Evergreen.V8.Pages.Sheet.Msg
    | VegaLite Evergreen.V8.Pages.VegaLite.Msg
