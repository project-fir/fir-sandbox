module Evergreen.V37.Gen.Model exposing (..)

import Evergreen.V37.Gen.Params.Admin
import Evergreen.V37.Gen.Params.ElmUiSvgIssue
import Evergreen.V37.Gen.Params.Home_
import Evergreen.V37.Gen.Params.Kimball
import Evergreen.V37.Gen.Params.NotFound
import Evergreen.V37.Gen.Params.Sheet
import Evergreen.V37.Gen.Params.Stories
import Evergreen.V37.Gen.Params.Stories.Basics
import Evergreen.V37.Gen.Params.VegaLite
import Evergreen.V37.Pages.Admin
import Evergreen.V37.Pages.ElmUiSvgIssue
import Evergreen.V37.Pages.Kimball
import Evergreen.V37.Pages.Sheet
import Evergreen.V37.Pages.Stories.Basics
import Evergreen.V37.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V37.Gen.Params.Admin.Params Evergreen.V37.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V37.Gen.Params.ElmUiSvgIssue.Params Evergreen.V37.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V37.Gen.Params.Home_.Params
    | Kimball Evergreen.V37.Gen.Params.Kimball.Params Evergreen.V37.Pages.Kimball.Model
    | Sheet Evergreen.V37.Gen.Params.Sheet.Params Evergreen.V37.Pages.Sheet.Model
    | Stories Evergreen.V37.Gen.Params.Stories.Params
    | VegaLite Evergreen.V37.Gen.Params.VegaLite.Params Evergreen.V37.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V37.Gen.Params.Stories.Basics.Params Evergreen.V37.Pages.Stories.Basics.Model
    | NotFound Evergreen.V37.Gen.Params.NotFound.Params
