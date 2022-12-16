module Evergreen.V52.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V52.DimensionalModel
import Evergreen.V52.DuckDb
import Evergreen.V52.Ui


type Msg
    = UserClickedErdCardColumn
    | UserHoveredOverErdCardColumn
    | UserToggledErdCardDropdown Evergreen.V52.DuckDb.DuckDbRef
    | UserToggledDummyDropdown
    | UserSelectedErdCardDropdownOption
    | UserHoveredOverOption
    | MouseEnteredErdCard
    | MouseLeftErdCard
    | UserClickedButton


type alias Model =
    { theme : Evergreen.V52.Ui.ColorTheme
    , dimModel : Evergreen.V52.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
