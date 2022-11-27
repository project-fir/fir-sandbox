module Evergreen.V39.Gen.Model exposing (..)

import Evergreen.V39.Gen.Params.Admin
import Evergreen.V39.Gen.Params.ElmUiSvgIssue
import Evergreen.V39.Gen.Params.Home_
import Evergreen.V39.Gen.Params.Kimball
import Evergreen.V39.Gen.Params.NotFound
import Evergreen.V39.Gen.Params.Sheet
import Evergreen.V39.Gen.Params.Stories
import Evergreen.V39.Gen.Params.Stories.Basics
import Evergreen.V39.Gen.Params.VegaLite
import Evergreen.V39.Pages.Admin
import Evergreen.V39.Pages.ElmUiSvgIssue
import Evergreen.V39.Pages.Kimball
import Evergreen.V39.Pages.Sheet
import Evergreen.V39.Pages.Stories.Basics
import Evergreen.V39.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V39.Gen.Params.Admin.Params Evergreen.V39.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V39.Gen.Params.ElmUiSvgIssue.Params Evergreen.V39.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V39.Gen.Params.Home_.Params
    | Kimball Evergreen.V39.Gen.Params.Kimball.Params Evergreen.V39.Pages.Kimball.Model
    | Sheet Evergreen.V39.Gen.Params.Sheet.Params Evergreen.V39.Pages.Sheet.Model
    | Stories Evergreen.V39.Gen.Params.Stories.Params
    | VegaLite Evergreen.V39.Gen.Params.VegaLite.Params Evergreen.V39.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V39.Gen.Params.Stories.Basics.Params Evergreen.V39.Pages.Stories.Basics.Model
    | NotFound Evergreen.V39.Gen.Params.NotFound.Params
