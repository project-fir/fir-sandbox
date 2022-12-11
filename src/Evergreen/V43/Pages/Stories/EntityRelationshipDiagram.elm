module Evergreen.V43.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V43.DimensionalModel
import Evergreen.V43.DuckDb
import Evergreen.V43.Ui


type Msg
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown Evergreen.V43.DuckDb.DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


type alias Model =
    { theme : Evergreen.V43.Ui.ColorTheme
    , dimModel : Evergreen.V43.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
