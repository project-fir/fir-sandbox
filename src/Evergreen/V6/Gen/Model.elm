module Evergreen.V6.Gen.Model exposing (..)

import Evergreen.V6.Gen.Params.Home_
import Evergreen.V6.Gen.Params.NotFound
import Evergreen.V6.Gen.Params.Sheet
import Evergreen.V6.Gen.Params.VegaLite
import Evergreen.V6.Pages.Sheet
import Evergreen.V6.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V6.Gen.Params.Home_.Params
    | Sheet Evergreen.V6.Gen.Params.Sheet.Params Evergreen.V6.Pages.Sheet.Model
    | VegaLite Evergreen.V6.Gen.Params.VegaLite.Params Evergreen.V6.Pages.VegaLite.Model
    | NotFound Evergreen.V6.Gen.Params.NotFound.Params
