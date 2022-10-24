module Evergreen.V33.Gen.Model exposing (..)

import Evergreen.V33.Gen.Params.Admin
import Evergreen.V33.Gen.Params.ElmUiSvgIssue
import Evergreen.V33.Gen.Params.Home_
import Evergreen.V33.Gen.Params.Kimball
import Evergreen.V33.Gen.Params.NotFound
import Evergreen.V33.Gen.Params.Sheet
import Evergreen.V33.Gen.Params.VegaLite
import Evergreen.V33.Pages.Admin
import Evergreen.V33.Pages.ElmUiSvgIssue
import Evergreen.V33.Pages.Kimball
import Evergreen.V33.Pages.Sheet
import Evergreen.V33.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V33.Gen.Params.Admin.Params Evergreen.V33.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V33.Gen.Params.ElmUiSvgIssue.Params Evergreen.V33.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V33.Gen.Params.Home_.Params
    | Kimball Evergreen.V33.Gen.Params.Kimball.Params Evergreen.V33.Pages.Kimball.Model
    | Sheet Evergreen.V33.Gen.Params.Sheet.Params Evergreen.V33.Pages.Sheet.Model
    | VegaLite Evergreen.V33.Gen.Params.VegaLite.Params Evergreen.V33.Pages.VegaLite.Model
    | NotFound Evergreen.V33.Gen.Params.NotFound.Params
