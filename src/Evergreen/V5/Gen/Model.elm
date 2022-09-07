module Evergreen.V5.Gen.Model exposing (..)

import Evergreen.V5.Gen.Params.Home_
import Evergreen.V5.Gen.Params.NotFound
import Evergreen.V5.Gen.Params.Sheet
import Evergreen.V5.Gen.Params.VegaLite
import Evergreen.V5.Pages.Sheet
import Evergreen.V5.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V5.Gen.Params.Home_.Params
    | Sheet Evergreen.V5.Gen.Params.Sheet.Params Evergreen.V5.Pages.Sheet.Model
    | VegaLite Evergreen.V5.Gen.Params.VegaLite.Params Evergreen.V5.Pages.VegaLite.Model
    | NotFound Evergreen.V5.Gen.Params.NotFound.Params
