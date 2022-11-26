module Evergreen.V38.Gen.Model exposing (..)

import Evergreen.V38.Gen.Params.Admin
import Evergreen.V38.Gen.Params.ElmUiSvgIssue
import Evergreen.V38.Gen.Params.Home_
import Evergreen.V38.Gen.Params.Kimball
import Evergreen.V38.Gen.Params.NotFound
import Evergreen.V38.Gen.Params.Sheet
import Evergreen.V38.Gen.Params.Stories
import Evergreen.V38.Gen.Params.Stories.Basics
import Evergreen.V38.Gen.Params.VegaLite
import Evergreen.V38.Pages.Admin
import Evergreen.V38.Pages.ElmUiSvgIssue
import Evergreen.V38.Pages.Kimball
import Evergreen.V38.Pages.Sheet
import Evergreen.V38.Pages.Stories.Basics
import Evergreen.V38.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V38.Gen.Params.Admin.Params Evergreen.V38.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V38.Gen.Params.ElmUiSvgIssue.Params Evergreen.V38.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V38.Gen.Params.Home_.Params
    | Kimball Evergreen.V38.Gen.Params.Kimball.Params Evergreen.V38.Pages.Kimball.Model
    | Sheet Evergreen.V38.Gen.Params.Sheet.Params Evergreen.V38.Pages.Sheet.Model
    | Stories Evergreen.V38.Gen.Params.Stories.Params
    | VegaLite Evergreen.V38.Gen.Params.VegaLite.Params Evergreen.V38.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V38.Gen.Params.Stories.Basics.Params Evergreen.V38.Pages.Stories.Basics.Model
    | NotFound Evergreen.V38.Gen.Params.NotFound.Params
