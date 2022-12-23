module Evergreen.V56.Pages.Stories.Basics exposing (..)

import Evergreen.V56.Ui


type alias Model =
    { theme : Evergreen.V56.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type alias MenuId =
    String


type Msg
    = Basics__UserSelectedPalette Evergreen.V56.Ui.PaletteName
    | UserToggledDrawer MenuId
    | MouseEnteredDropDownMenu MenuId
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
