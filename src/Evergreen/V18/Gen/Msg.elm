module Evergreen.V18.Gen.Msg exposing (..)

import Evergreen.V18.Pages.Admin
import Evergreen.V18.Pages.Kimball
import Evergreen.V18.Pages.Sheet
import Evergreen.V18.Pages.VegaLite


type Msg
    = Admin Evergreen.V18.Pages.Admin.Msg
    | Kimball Evergreen.V18.Pages.Kimball.Msg
    | Sheet Evergreen.V18.Pages.Sheet.Msg
    | VegaLite Evergreen.V18.Pages.VegaLite.Msg
