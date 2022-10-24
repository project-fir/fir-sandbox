module Evergreen.V33.Gen.Msg exposing (..)

import Evergreen.V33.Pages.Admin
import Evergreen.V33.Pages.ElmUiSvgIssue
import Evergreen.V33.Pages.Kimball
import Evergreen.V33.Pages.Sheet
import Evergreen.V33.Pages.VegaLite


type Msg
    = Admin Evergreen.V33.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V33.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V33.Pages.Kimball.Msg
    | Sheet Evergreen.V33.Pages.Sheet.Msg
    | VegaLite Evergreen.V33.Pages.VegaLite.Msg
