module Evergreen.V49.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V49.DimensionalModel
import Evergreen.V49.DuckDb
import Evergreen.V49.Ui


type Msg
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown Evergreen.V49.DuckDb.DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


type alias Model =
    { theme : Evergreen.V49.Ui.ColorTheme
    , dimModel : Evergreen.V49.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
