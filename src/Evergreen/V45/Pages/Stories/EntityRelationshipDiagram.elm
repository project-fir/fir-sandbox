module Evergreen.V45.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V45.DimensionalModel
import Evergreen.V45.DuckDb
import Evergreen.V45.Ui


type Msg
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown Evergreen.V45.DuckDb.DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


type alias Model =
    { theme : Evergreen.V45.Ui.ColorTheme
    , dimModel : Evergreen.V45.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
