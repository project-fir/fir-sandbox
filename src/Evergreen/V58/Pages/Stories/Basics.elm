module Evergreen.V58.Pages.Stories.Basics exposing (..)

import Evergreen.V58.Ui


type alias Model =
    { theme : Evergreen.V58.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type alias MenuId =
    String


type Msg
    = Basics__UserSelectedPalette Evergreen.V58.Ui.PaletteName
    | UserToggledDrawer MenuId
    | MouseEnteredDropDownMenu MenuId
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
