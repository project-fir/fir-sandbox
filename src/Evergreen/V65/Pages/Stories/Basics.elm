module Evergreen.V65.Pages.Stories.Basics exposing (..)

import Evergreen.V65.Ui


type alias Model =
    { theme : Evergreen.V65.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type alias MenuId =
    String


type Msg
    = Basics__UserSelectedPalette Evergreen.V65.Ui.PaletteName
    | UserToggledDrawer MenuId
    | MouseEnteredDropDownMenu MenuId
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
