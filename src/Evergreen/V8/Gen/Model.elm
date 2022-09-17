module Evergreen.V8.Gen.Model exposing (..)

import Evergreen.V8.Gen.Params.Home_
import Evergreen.V8.Gen.Params.Kimball
import Evergreen.V8.Gen.Params.NotFound
import Evergreen.V8.Gen.Params.Sheet
import Evergreen.V8.Gen.Params.VegaLite
import Evergreen.V8.Pages.Kimball
import Evergreen.V8.Pages.Sheet
import Evergreen.V8.Pages.VegaLite


type Model
    = Redirecting_
    | Home_ Evergreen.V8.Gen.Params.Home_.Params
    | Kimball Evergreen.V8.Gen.Params.Kimball.Params Evergreen.V8.Pages.Kimball.Model
    | Sheet Evergreen.V8.Gen.Params.Sheet.Params Evergreen.V8.Pages.Sheet.Model
    | VegaLite Evergreen.V8.Gen.Params.VegaLite.Params Evergreen.V8.Pages.VegaLite.Model
    | NotFound Evergreen.V8.Gen.Params.NotFound.Params
