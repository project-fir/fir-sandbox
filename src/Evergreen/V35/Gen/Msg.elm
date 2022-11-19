module Evergreen.V35.Gen.Msg exposing (..)

import Evergreen.V35.Pages.Admin
import Evergreen.V35.Pages.ElmUiSvgIssue
import Evergreen.V35.Pages.Kimball
import Evergreen.V35.Pages.Sheet
import Evergreen.V35.Pages.VegaLite


type Msg
    = Admin Evergreen.V35.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V35.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V35.Pages.Kimball.Msg
    | Sheet Evergreen.V35.Pages.Sheet.Msg
    | VegaLite Evergreen.V35.Pages.VegaLite.Msg
