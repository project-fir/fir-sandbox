module Evergreen.V30.Gen.Model exposing (..)

import Evergreen.V30.Gen.Params.Admin
import Evergreen.V30.Gen.Params.ElmUiSvgIssue
import Evergreen.V30.Gen.Params.Home_
import Evergreen.V30.Gen.Params.Kimball
import Evergreen.V30.Gen.Params.NotFound
import Evergreen.V30.Gen.Params.Sheet
import Evergreen.V30.Gen.Params.VegaLite
import Evergreen.V30.Pages.Admin
import Evergreen.V30.Pages.ElmUiSvgIssue
import Evergreen.V30.Pages.Kimball
import Evergreen.V30.Pages.Sheet
import Evergreen.V30.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V30.Gen.Params.Admin.Params Evergreen.V30.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V30.Gen.Params.ElmUiSvgIssue.Params Evergreen.V30.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V30.Gen.Params.Home_.Params
    | Kimball Evergreen.V30.Gen.Params.Kimball.Params Evergreen.V30.Pages.Kimball.Model
    | Sheet Evergreen.V30.Gen.Params.Sheet.Params Evergreen.V30.Pages.Sheet.Model
    | VegaLite Evergreen.V30.Gen.Params.VegaLite.Params Evergreen.V30.Pages.VegaLite.Model
    | NotFound Evergreen.V30.Gen.Params.NotFound.Params
