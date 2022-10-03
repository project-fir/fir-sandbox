module Evergreen.V26.Gen.Msg exposing (..)

import Evergreen.V26.Pages.Admin
import Evergreen.V26.Pages.Kimball
import Evergreen.V26.Pages.Sheet
import Evergreen.V26.Pages.VegaLite


type Msg
    = Admin Evergreen.V26.Pages.Admin.Msg
    | Kimball Evergreen.V26.Pages.Kimball.Msg
    | Sheet Evergreen.V26.Pages.Sheet.Msg
    | VegaLite Evergreen.V26.Pages.VegaLite.Msg
