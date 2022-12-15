module Evergreen.V46.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V46.DimensionalModel
import Evergreen.V46.DuckDb
import Evergreen.V46.Ui


type Msg
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown Evergreen.V46.DuckDb.DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


type alias Model =
    { theme : Evergreen.V46.Ui.ColorTheme
    , dimModel : Evergreen.V46.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
