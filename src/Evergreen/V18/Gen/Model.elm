module Evergreen.V18.Gen.Model exposing (..)

import Evergreen.V18.Gen.Params.Admin
import Evergreen.V18.Gen.Params.Home_
import Evergreen.V18.Gen.Params.Kimball
import Evergreen.V18.Gen.Params.NotFound
import Evergreen.V18.Gen.Params.Sheet
import Evergreen.V18.Gen.Params.VegaLite
import Evergreen.V18.Pages.Admin
import Evergreen.V18.Pages.Kimball
import Evergreen.V18.Pages.Sheet
import Evergreen.V18.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V18.Gen.Params.Admin.Params Evergreen.V18.Pages.Admin.Model
    | Home_ Evergreen.V18.Gen.Params.Home_.Params
    | Kimball Evergreen.V18.Gen.Params.Kimball.Params Evergreen.V18.Pages.Kimball.Model
    | Sheet Evergreen.V18.Gen.Params.Sheet.Params Evergreen.V18.Pages.Sheet.Model
    | VegaLite Evergreen.V18.Gen.Params.VegaLite.Params Evergreen.V18.Pages.VegaLite.Model
    | NotFound Evergreen.V18.Gen.Params.NotFound.Params
