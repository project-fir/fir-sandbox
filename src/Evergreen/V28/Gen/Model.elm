module Evergreen.V28.Gen.Model exposing (..)

import Evergreen.V28.Gen.Params.Admin
import Evergreen.V28.Gen.Params.Home_
import Evergreen.V28.Gen.Params.Kimball
import Evergreen.V28.Gen.Params.NotFound
import Evergreen.V28.Gen.Params.Sheet
import Evergreen.V28.Gen.Params.VegaLite
import Evergreen.V28.Pages.Admin
import Evergreen.V28.Pages.Kimball
import Evergreen.V28.Pages.Sheet
import Evergreen.V28.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V28.Gen.Params.Admin.Params Evergreen.V28.Pages.Admin.Model
    | Home_ Evergreen.V28.Gen.Params.Home_.Params
    | Kimball Evergreen.V28.Gen.Params.Kimball.Params Evergreen.V28.Pages.Kimball.Model
    | Sheet Evergreen.V28.Gen.Params.Sheet.Params Evergreen.V28.Pages.Sheet.Model
    | VegaLite Evergreen.V28.Gen.Params.VegaLite.Params Evergreen.V28.Pages.VegaLite.Model
    | NotFound Evergreen.V28.Gen.Params.NotFound.Params
