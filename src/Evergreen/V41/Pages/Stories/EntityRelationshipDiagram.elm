module Evergreen.V41.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V41.DimensionalModel
import Evergreen.V41.DuckDb
import Evergreen.V41.Ui


type Msg
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown Evergreen.V41.DuckDb.DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


type alias Model =
    { theme : Evergreen.V41.Ui.ColorTheme
    , dimModel : Evergreen.V41.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
