module Evergreen.V22.Gen.Msg exposing (..)

import Evergreen.V22.Pages.Admin
import Evergreen.V22.Pages.Kimball
import Evergreen.V22.Pages.Sheet
import Evergreen.V22.Pages.VegaLite


type Msg
    = Admin Evergreen.V22.Pages.Admin.Msg
    | Kimball Evergreen.V22.Pages.Kimball.Msg
    | Sheet Evergreen.V22.Pages.Sheet.Msg
    | VegaLite Evergreen.V22.Pages.VegaLite.Msg
