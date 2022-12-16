module Evergreen.V48.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V48.DimensionalModel
import Evergreen.V48.DuckDb
import Evergreen.V48.Ui


type Msg
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown Evergreen.V48.DuckDb.DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


type alias Model =
    { theme : Evergreen.V48.Ui.ColorTheme
    , dimModel : Evergreen.V48.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
