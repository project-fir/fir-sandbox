module Evergreen.V21.Gen.Model exposing (..)

import Evergreen.V21.Gen.Params.Admin
import Evergreen.V21.Gen.Params.Home_
import Evergreen.V21.Gen.Params.Kimball
import Evergreen.V21.Gen.Params.NotFound
import Evergreen.V21.Gen.Params.Sheet
import Evergreen.V21.Gen.Params.VegaLite
import Evergreen.V21.Pages.Admin
import Evergreen.V21.Pages.Kimball
import Evergreen.V21.Pages.Sheet
import Evergreen.V21.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V21.Gen.Params.Admin.Params Evergreen.V21.Pages.Admin.Model
    | Home_ Evergreen.V21.Gen.Params.Home_.Params
    | Kimball Evergreen.V21.Gen.Params.Kimball.Params Evergreen.V21.Pages.Kimball.Model
    | Sheet Evergreen.V21.Gen.Params.Sheet.Params Evergreen.V21.Pages.Sheet.Model
    | VegaLite Evergreen.V21.Gen.Params.VegaLite.Params Evergreen.V21.Pages.VegaLite.Model
    | NotFound Evergreen.V21.Gen.Params.NotFound.Params
