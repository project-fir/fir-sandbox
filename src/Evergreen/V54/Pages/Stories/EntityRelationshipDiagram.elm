module Evergreen.V54.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V54.DimensionalModel
import Evergreen.V54.DuckDb
import Evergreen.V54.Ui


type Msg
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown Evergreen.V54.DuckDb.DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


type alias Model =
    { theme : Evergreen.V54.Ui.ColorTheme
    , dimModel : Evergreen.V54.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
