module Evergreen.V17.Gen.Model exposing (..)

import Evergreen.V17.Gen.Params.Admin
import Evergreen.V17.Gen.Params.Home_
import Evergreen.V17.Gen.Params.Kimball
import Evergreen.V17.Gen.Params.NotFound
import Evergreen.V17.Gen.Params.Sheet
import Evergreen.V17.Gen.Params.VegaLite
import Evergreen.V17.Pages.Admin
import Evergreen.V17.Pages.Kimball
import Evergreen.V17.Pages.Sheet
import Evergreen.V17.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V17.Gen.Params.Admin.Params Evergreen.V17.Pages.Admin.Model
    | Home_ Evergreen.V17.Gen.Params.Home_.Params
    | Kimball Evergreen.V17.Gen.Params.Kimball.Params Evergreen.V17.Pages.Kimball.Model
    | Sheet Evergreen.V17.Gen.Params.Sheet.Params Evergreen.V17.Pages.Sheet.Model
    | VegaLite Evergreen.V17.Gen.Params.VegaLite.Params Evergreen.V17.Pages.VegaLite.Model
    | NotFound Evergreen.V17.Gen.Params.NotFound.Params
