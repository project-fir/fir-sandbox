module Evergreen.V16.Gen.Model exposing (..)

import Evergreen.V16.Gen.Params.Home_
import Evergreen.V16.Gen.Params.Kimball
import Evergreen.V16.Gen.Params.NotFound
import Evergreen.V16.Gen.Params.Sheet
import Evergreen.V16.Gen.Params.VegaLite
import Evergreen.V16.Pages.Kimball
import Evergreen.V16.Pages.Sheet
import Evergreen.V16.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V16.Gen.Params.Home_.Params
    | Kimball Evergreen.V16.Gen.Params.Kimball.Params Evergreen.V16.Pages.Kimball.Model
    | Sheet Evergreen.V16.Gen.Params.Sheet.Params Evergreen.V16.Pages.Sheet.Model
    | VegaLite Evergreen.V16.Gen.Params.VegaLite.Params Evergreen.V16.Pages.VegaLite.Model
    | NotFound Evergreen.V16.Gen.Params.NotFound.Params
