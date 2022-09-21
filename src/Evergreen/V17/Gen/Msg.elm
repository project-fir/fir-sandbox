module Evergreen.V17.Gen.Msg exposing (..)

import Evergreen.V17.Pages.Admin
import Evergreen.V17.Pages.Kimball
import Evergreen.V17.Pages.Sheet
import Evergreen.V17.Pages.VegaLite


type Msg
    = Admin Evergreen.V17.Pages.Admin.Msg
    | Kimball Evergreen.V17.Pages.Kimball.Msg
    | Sheet Evergreen.V17.Pages.Sheet.Msg
    | VegaLite Evergreen.V17.Pages.VegaLite.Msg
