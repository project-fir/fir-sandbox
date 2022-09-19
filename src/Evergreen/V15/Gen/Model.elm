module Evergreen.V15.Gen.Model exposing (..)

import Evergreen.V15.Gen.Params.Home_
import Evergreen.V15.Gen.Params.Kimball
import Evergreen.V15.Gen.Params.NotFound
import Evergreen.V15.Gen.Params.Sheet
import Evergreen.V15.Gen.Params.VegaLite
import Evergreen.V15.Pages.Kimball
import Evergreen.V15.Pages.Sheet
import Evergreen.V15.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V15.Gen.Params.Home_.Params
    | Kimball Evergreen.V15.Gen.Params.Kimball.Params Evergreen.V15.Pages.Kimball.Model
    | Sheet Evergreen.V15.Gen.Params.Sheet.Params Evergreen.V15.Pages.Sheet.Model
    | VegaLite Evergreen.V15.Gen.Params.VegaLite.Params Evergreen.V15.Pages.VegaLite.Model
    | NotFound Evergreen.V15.Gen.Params.NotFound.Params
