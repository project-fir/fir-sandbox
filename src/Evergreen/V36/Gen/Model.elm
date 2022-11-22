module Evergreen.V36.Gen.Model exposing (..)

import Evergreen.V36.Gen.Params.Admin
import Evergreen.V36.Gen.Params.ElmUiSvgIssue
import Evergreen.V36.Gen.Params.Home_
import Evergreen.V36.Gen.Params.Kimball
import Evergreen.V36.Gen.Params.NotFound
import Evergreen.V36.Gen.Params.Sheet
import Evergreen.V36.Gen.Params.Stories
import Evergreen.V36.Gen.Params.Stories.Basics
import Evergreen.V36.Gen.Params.VegaLite
import Evergreen.V36.Pages.Admin
import Evergreen.V36.Pages.ElmUiSvgIssue
import Evergreen.V36.Pages.Kimball
import Evergreen.V36.Pages.Sheet
import Evergreen.V36.Pages.Stories.Basics
import Evergreen.V36.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V36.Gen.Params.Admin.Params Evergreen.V36.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V36.Gen.Params.ElmUiSvgIssue.Params Evergreen.V36.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V36.Gen.Params.Home_.Params
    | Kimball Evergreen.V36.Gen.Params.Kimball.Params Evergreen.V36.Pages.Kimball.Model
    | Sheet Evergreen.V36.Gen.Params.Sheet.Params Evergreen.V36.Pages.Sheet.Model
    | Stories Evergreen.V36.Gen.Params.Stories.Params
    | VegaLite Evergreen.V36.Gen.Params.VegaLite.Params Evergreen.V36.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V36.Gen.Params.Stories.Basics.Params Evergreen.V36.Pages.Stories.Basics.Model
    | NotFound Evergreen.V36.Gen.Params.NotFound.Params
