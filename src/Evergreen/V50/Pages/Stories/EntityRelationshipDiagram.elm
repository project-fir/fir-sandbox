module Evergreen.V50.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V50.DimensionalModel
import Evergreen.V50.DuckDb
import Evergreen.V50.Ui


type Msg
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown Evergreen.V50.DuckDb.DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


type alias Model =
    { theme : Evergreen.V50.Ui.ColorTheme
    , dimModel : Evergreen.V50.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
