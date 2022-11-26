module Evergreen.V38.Gen.Msg exposing (..)

import Evergreen.V38.Pages.Admin
import Evergreen.V38.Pages.ElmUiSvgIssue
import Evergreen.V38.Pages.Kimball
import Evergreen.V38.Pages.Sheet
import Evergreen.V38.Pages.Stories.Basics
import Evergreen.V38.Pages.VegaLite


type Msg
    = Admin Evergreen.V38.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V38.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V38.Pages.Kimball.Msg
    | Sheet Evergreen.V38.Pages.Sheet.Msg
    | VegaLite Evergreen.V38.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V38.Pages.Stories.Basics.Msg
