module Evergreen.V13.Gen.Model exposing (..)

import Evergreen.V13.Gen.Params.Home_
import Evergreen.V13.Gen.Params.Kimball
import Evergreen.V13.Gen.Params.NotFound
import Evergreen.V13.Gen.Params.Sheet
import Evergreen.V13.Gen.Params.VegaLite
import Evergreen.V13.Pages.Kimball
import Evergreen.V13.Pages.Sheet
import Evergreen.V13.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V13.Gen.Params.Home_.Params
    | Kimball Evergreen.V13.Gen.Params.Kimball.Params Evergreen.V13.Pages.Kimball.Model
    | Sheet Evergreen.V13.Gen.Params.Sheet.Params Evergreen.V13.Pages.Sheet.Model
    | VegaLite Evergreen.V13.Gen.Params.VegaLite.Params Evergreen.V13.Pages.VegaLite.Model
    | NotFound Evergreen.V13.Gen.Params.NotFound.Params
