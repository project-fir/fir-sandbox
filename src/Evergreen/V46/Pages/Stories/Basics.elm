module Evergreen.V46.Pages.Stories.Basics exposing (..)

import Evergreen.V46.Ui


type alias Model =
    { theme : Evergreen.V46.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type Msg
    = Basics__UserSelectedPalette Evergreen.V46.Ui.PaletteName
    | UserToggledDrawer
    | MouseEnteredDropDownMenu
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
