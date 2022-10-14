module Evergreen.V29.Gen.Model exposing (..)

import Evergreen.V29.Gen.Params.Admin
import Evergreen.V29.Gen.Params.Home_
import Evergreen.V29.Gen.Params.Kimball
import Evergreen.V29.Gen.Params.NotFound
import Evergreen.V29.Gen.Params.Sheet
import Evergreen.V29.Gen.Params.VegaLite
import Evergreen.V29.Pages.Admin
import Evergreen.V29.Pages.Kimball
import Evergreen.V29.Pages.Sheet
import Evergreen.V29.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V29.Gen.Params.Admin.Params Evergreen.V29.Pages.Admin.Model
    | Home_ Evergreen.V29.Gen.Params.Home_.Params
    | Kimball Evergreen.V29.Gen.Params.Kimball.Params Evergreen.V29.Pages.Kimball.Model
    | Sheet Evergreen.V29.Gen.Params.Sheet.Params Evergreen.V29.Pages.Sheet.Model
    | VegaLite Evergreen.V29.Gen.Params.VegaLite.Params Evergreen.V29.Pages.VegaLite.Model
    | NotFound Evergreen.V29.Gen.Params.NotFound.Params
