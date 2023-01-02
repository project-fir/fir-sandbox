module Evergreen.V64.Pages.Stories.Basics exposing (..)

import Evergreen.V64.Ui


type alias Model =
    { theme : Evergreen.V64.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type alias MenuId =
    String


type Msg
    = Basics__UserSelectedPalette Evergreen.V64.Ui.PaletteName
    | UserToggledDrawer MenuId
    | MouseEnteredDropDownMenu MenuId
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
