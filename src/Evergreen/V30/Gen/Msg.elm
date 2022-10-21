module Evergreen.V30.Gen.Msg exposing (..)

import Evergreen.V30.Pages.Admin
import Evergreen.V30.Pages.ElmUiSvgIssue
import Evergreen.V30.Pages.Kimball
import Evergreen.V30.Pages.Sheet
import Evergreen.V30.Pages.VegaLite


type Msg
    = Admin Evergreen.V30.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V30.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V30.Pages.Kimball.Msg
    | Sheet Evergreen.V30.Pages.Sheet.Msg
    | VegaLite Evergreen.V30.Pages.VegaLite.Msg
