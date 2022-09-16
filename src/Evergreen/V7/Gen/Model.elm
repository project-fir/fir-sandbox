module Evergreen.V7.Gen.Model exposing (..)

import Evergreen.V7.Gen.Params.Home_
import Evergreen.V7.Gen.Params.NotFound
import Evergreen.V7.Gen.Params.Sheet
import Evergreen.V7.Gen.Params.VegaLite
import Evergreen.V7.Pages.Sheet
import Evergreen.V7.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V7.Gen.Params.Home_.Params
    | Sheet Evergreen.V7.Gen.Params.Sheet.Params Evergreen.V7.Pages.Sheet.Model
    | VegaLite Evergreen.V7.Gen.Params.VegaLite.Params Evergreen.V7.Pages.VegaLite.Model
    | NotFound Evergreen.V7.Gen.Params.NotFound.Params
