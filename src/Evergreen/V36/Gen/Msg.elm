module Evergreen.V36.Gen.Msg exposing (..)

import Evergreen.V36.Pages.Admin
import Evergreen.V36.Pages.ElmUiSvgIssue
import Evergreen.V36.Pages.Kimball
import Evergreen.V36.Pages.Sheet
import Evergreen.V36.Pages.Stories.Basics
import Evergreen.V36.Pages.VegaLite


type Msg
    = Admin Evergreen.V36.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V36.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V36.Pages.Kimball.Msg
    | Sheet Evergreen.V36.Pages.Sheet.Msg
    | VegaLite Evergreen.V36.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V36.Pages.Stories.Basics.Msg
