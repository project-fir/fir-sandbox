module Evergreen.V39.Gen.Msg exposing (..)

import Evergreen.V39.Pages.Admin
import Evergreen.V39.Pages.ElmUiSvgIssue
import Evergreen.V39.Pages.Kimball
import Evergreen.V39.Pages.Sheet
import Evergreen.V39.Pages.Stories.Basics
import Evergreen.V39.Pages.VegaLite


type Msg
    = Admin Evergreen.V39.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V39.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V39.Pages.Kimball.Msg
    | Sheet Evergreen.V39.Pages.Sheet.Msg
    | VegaLite Evergreen.V39.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V39.Pages.Stories.Basics.Msg
