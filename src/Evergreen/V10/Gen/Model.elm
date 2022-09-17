module Evergreen.V10.Gen.Model exposing (..)

import Evergreen.V10.Gen.Params.Home_
import Evergreen.V10.Gen.Params.Kimball
import Evergreen.V10.Gen.Params.NotFound
import Evergreen.V10.Gen.Params.Sheet
import Evergreen.V10.Gen.Params.VegaLite
import Evergreen.V10.Pages.Kimball
import Evergreen.V10.Pages.Sheet
import Evergreen.V10.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V10.Gen.Params.Home_.Params
    | Kimball Evergreen.V10.Gen.Params.Kimball.Params Evergreen.V10.Pages.Kimball.Model
    | Sheet Evergreen.V10.Gen.Params.Sheet.Params Evergreen.V10.Pages.Sheet.Model
    | VegaLite Evergreen.V10.Gen.Params.VegaLite.Params Evergreen.V10.Pages.VegaLite.Model
    | NotFound Evergreen.V10.Gen.Params.NotFound.Params
