module Evergreen.V62.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V62.DimensionalModel
import Evergreen.V62.DuckDb
import Evergreen.V62.Ui
import Html.Events.Extra.Mouse


type Msg
    = MouseEnteredErdCard Evergreen.V62.DuckDb.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V62.DuckDb.DuckDbRef Evergreen.V62.DuckDb.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V62.DuckDb.DuckDbRef Evergreen.V62.DuckDb.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V62.DuckDb.DuckDbRef
    | MouseEnteredErdCardDropdown Evergreen.V62.DuckDb.DuckDbRef
    | MouseLeftErdCardDropdown
    | ClickedErdCardDropdownOption Evergreen.V62.DimensionalModel.DimensionalModelRef Evergreen.V62.DuckDb.DuckDbRef (Evergreen.V62.DimensionalModel.KimballAssignment Evergreen.V62.DuckDb.DuckDbRef_ (List Evergreen.V62.DuckDb.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V62.DuckDb.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event


type alias Model =
    { theme : Evergreen.V62.Ui.ColorTheme
    , dimModel1 : Evergreen.V62.DimensionalModel.DimensionalModel
    , dimModel2 : Evergreen.V62.DimensionalModel.DimensionalModel
    , dimModel3 : Evergreen.V62.DimensionalModel.DimensionalModel
    , dimModel4 : Evergreen.V62.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
