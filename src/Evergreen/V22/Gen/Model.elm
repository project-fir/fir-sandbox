module Evergreen.V22.Gen.Model exposing (..)

import Evergreen.V22.Gen.Params.Admin
import Evergreen.V22.Gen.Params.Home_
import Evergreen.V22.Gen.Params.Kimball
import Evergreen.V22.Gen.Params.NotFound
import Evergreen.V22.Gen.Params.Sheet
import Evergreen.V22.Gen.Params.VegaLite
import Evergreen.V22.Pages.Admin
import Evergreen.V22.Pages.Kimball
import Evergreen.V22.Pages.Sheet
import Evergreen.V22.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V22.Gen.Params.Admin.Params Evergreen.V22.Pages.Admin.Model
    | Home_ Evergreen.V22.Gen.Params.Home_.Params
    | Kimball Evergreen.V22.Gen.Params.Kimball.Params Evergreen.V22.Pages.Kimball.Model
    | Sheet Evergreen.V22.Gen.Params.Sheet.Params Evergreen.V22.Pages.Sheet.Model
    | VegaLite Evergreen.V22.Gen.Params.VegaLite.Params Evergreen.V22.Pages.VegaLite.Model
    | NotFound Evergreen.V22.Gen.Params.NotFound.Params
