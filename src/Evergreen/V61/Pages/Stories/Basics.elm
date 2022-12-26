module Evergreen.V61.Pages.Stories.Basics exposing (..)

import Evergreen.V61.Ui


type alias Model =
    { theme : Evergreen.V61.Ui.ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


type alias MenuId =
    String


type Msg
    = Basics__UserSelectedPalette Evergreen.V61.Ui.PaletteName
    | UserToggledDrawer MenuId
    | MouseEnteredDropDownMenu MenuId
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop
