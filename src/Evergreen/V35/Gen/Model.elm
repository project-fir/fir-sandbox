module Evergreen.V35.Gen.Model exposing (..)

import Evergreen.V35.Gen.Params.Admin
import Evergreen.V35.Gen.Params.ElmUiSvgIssue
import Evergreen.V35.Gen.Params.Home_
import Evergreen.V35.Gen.Params.Kimball
import Evergreen.V35.Gen.Params.NotFound
import Evergreen.V35.Gen.Params.Sheet
import Evergreen.V35.Gen.Params.Stories
import Evergreen.V35.Gen.Params.Stories.Basics
import Evergreen.V35.Gen.Params.VegaLite
import Evergreen.V35.Pages.Admin
import Evergreen.V35.Pages.ElmUiSvgIssue
import Evergreen.V35.Pages.Kimball
import Evergreen.V35.Pages.Sheet
import Evergreen.V35.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V35.Gen.Params.Admin.Params Evergreen.V35.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V35.Gen.Params.ElmUiSvgIssue.Params Evergreen.V35.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V35.Gen.Params.Home_.Params
    | Kimball Evergreen.V35.Gen.Params.Kimball.Params Evergreen.V35.Pages.Kimball.Model
    | Sheet Evergreen.V35.Gen.Params.Sheet.Params Evergreen.V35.Pages.Sheet.Model
    | Stories Evergreen.V35.Gen.Params.Stories.Params
    | VegaLite Evergreen.V35.Gen.Params.VegaLite.Params Evergreen.V35.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V35.Gen.Params.Stories.Basics.Params
    | NotFound Evergreen.V35.Gen.Params.NotFound.Params
