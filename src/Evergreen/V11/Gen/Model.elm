module Evergreen.V11.Gen.Model exposing (..)

import Evergreen.V11.Gen.Params.Home_
import Evergreen.V11.Gen.Params.Kimball
import Evergreen.V11.Gen.Params.NotFound
import Evergreen.V11.Gen.Params.Sheet
import Evergreen.V11.Gen.Params.VegaLite
import Evergreen.V11.Pages.Kimball
import Evergreen.V11.Pages.Sheet
import Evergreen.V11.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V11.Gen.Params.Home_.Params
    | Kimball Evergreen.V11.Gen.Params.Kimball.Params Evergreen.V11.Pages.Kimball.Model
    | Sheet Evergreen.V11.Gen.Params.Sheet.Params Evergreen.V11.Pages.Sheet.Model
    | VegaLite Evergreen.V11.Gen.Params.VegaLite.Params Evergreen.V11.Pages.VegaLite.Model
    | NotFound Evergreen.V11.Gen.Params.NotFound.Params
