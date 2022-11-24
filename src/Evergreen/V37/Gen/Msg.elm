module Evergreen.V37.Gen.Msg exposing (..)

import Evergreen.V37.Pages.Admin
import Evergreen.V37.Pages.ElmUiSvgIssue
import Evergreen.V37.Pages.Kimball
import Evergreen.V37.Pages.Sheet
import Evergreen.V37.Pages.Stories.Basics
import Evergreen.V37.Pages.VegaLite


type Msg
    = Admin Evergreen.V37.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V37.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V37.Pages.Kimball.Msg
    | Sheet Evergreen.V37.Pages.Sheet.Msg
    | VegaLite Evergreen.V37.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V37.Pages.Stories.Basics.Msg
