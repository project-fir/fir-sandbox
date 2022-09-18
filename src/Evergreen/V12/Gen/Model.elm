module Evergreen.V12.Gen.Model exposing (..)

import Evergreen.V12.Gen.Params.Home_
import Evergreen.V12.Gen.Params.Kimball
import Evergreen.V12.Gen.Params.NotFound
import Evergreen.V12.Gen.Params.Sheet
import Evergreen.V12.Gen.Params.VegaLite
import Evergreen.V12.Pages.Kimball
import Evergreen.V12.Pages.Sheet
import Evergreen.V12.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V12.Gen.Params.Home_.Params
    | Kimball Evergreen.V12.Gen.Params.Kimball.Params Evergreen.V12.Pages.Kimball.Model
    | Sheet Evergreen.V12.Gen.Params.Sheet.Params Evergreen.V12.Pages.Sheet.Model
    | VegaLite Evergreen.V12.Gen.Params.VegaLite.Params Evergreen.V12.Pages.VegaLite.Model
    | NotFound Evergreen.V12.Gen.Params.NotFound.Params
