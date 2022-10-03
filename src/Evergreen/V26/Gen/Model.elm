module Evergreen.V26.Gen.Model exposing (..)

import Evergreen.V26.Gen.Params.Admin
import Evergreen.V26.Gen.Params.Home_
import Evergreen.V26.Gen.Params.Kimball
import Evergreen.V26.Gen.Params.NotFound
import Evergreen.V26.Gen.Params.Sheet
import Evergreen.V26.Gen.Params.VegaLite
import Evergreen.V26.Pages.Admin
import Evergreen.V26.Pages.Kimball
import Evergreen.V26.Pages.Sheet
import Evergreen.V26.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V26.Gen.Params.Admin.Params Evergreen.V26.Pages.Admin.Model
    | Home_ Evergreen.V26.Gen.Params.Home_.Params
    | Kimball Evergreen.V26.Gen.Params.Kimball.Params Evergreen.V26.Pages.Kimball.Model
    | Sheet Evergreen.V26.Gen.Params.Sheet.Params Evergreen.V26.Pages.Sheet.Model
    | VegaLite Evergreen.V26.Gen.Params.VegaLite.Params Evergreen.V26.Pages.VegaLite.Model
    | NotFound Evergreen.V26.Gen.Params.NotFound.Params
