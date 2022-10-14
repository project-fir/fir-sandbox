module Evergreen.V28.Gen.Msg exposing (..)

import Evergreen.V28.Pages.Admin
import Evergreen.V28.Pages.Kimball
import Evergreen.V28.Pages.Sheet
import Evergreen.V28.Pages.VegaLite


type Msg
    = Admin Evergreen.V28.Pages.Admin.Msg
    | Kimball Evergreen.V28.Pages.Kimball.Msg
    | Sheet Evergreen.V28.Pages.Sheet.Msg
    | VegaLite Evergreen.V28.Pages.VegaLite.Msg
