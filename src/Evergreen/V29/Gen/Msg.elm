module Evergreen.V29.Gen.Msg exposing (..)

import Evergreen.V29.Pages.Admin
import Evergreen.V29.Pages.Kimball
import Evergreen.V29.Pages.Sheet
import Evergreen.V29.Pages.VegaLite


type Msg
    = Admin Evergreen.V29.Pages.Admin.Msg
    | Kimball Evergreen.V29.Pages.Kimball.Msg
    | Sheet Evergreen.V29.Pages.Sheet.Msg
    | VegaLite Evergreen.V29.Pages.VegaLite.Msg
