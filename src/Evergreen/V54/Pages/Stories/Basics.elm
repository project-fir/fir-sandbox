module Evergreen.V54.Pages.Stories.Basics exposing (..)

import Evergreen.V54.Ui


type alias Model =
    { theme : Evergreen.V54.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type Msg
    = Basics__UserSelectedPalette Evergreen.V54.Ui.PaletteName
    | UserToggledDrawer
    | MouseEnteredDropDownMenu
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
