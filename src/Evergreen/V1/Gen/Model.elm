module Evergreen.V1.Gen.Model exposing (..)

import Evergreen.V1.Gen.Params.Home_
import Evergreen.V1.Gen.Params.NotFound
import Evergreen.V1.Gen.Params.Sheet
import Evergreen.V1.Gen.Params.VegaLite
import Evergreen.V1.Pages.Sheet
import Evergreen.V1.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V1.Gen.Params.Home_.Params
    | Sheet Evergreen.V1.Gen.Params.Sheet.Params Evergreen.V1.Pages.Sheet.Model
    | VegaLite Evergreen.V1.Gen.Params.VegaLite.Params Evergreen.V1.Pages.VegaLite.Model
    | NotFound Evergreen.V1.Gen.Params.NotFound.Params
