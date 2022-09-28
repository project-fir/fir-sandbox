module Evergreen.V21.Gen.Msg exposing (..)

import Evergreen.V21.Pages.Admin
import Evergreen.V21.Pages.Kimball
import Evergreen.V21.Pages.Sheet
import Evergreen.V21.Pages.VegaLite


type Msg
    = Admin Evergreen.V21.Pages.Admin.Msg
    | Kimball Evergreen.V21.Pages.Kimball.Msg
    | Sheet Evergreen.V21.Pages.Sheet.Msg
    | VegaLite Evergreen.V21.Pages.VegaLite.Msg
