module Evergreen.V58.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V58.DimensionalModel
import Evergreen.V58.DuckDb
import Evergreen.V58.Ui
import Html.Events.Extra.Mouse


type Msg
    = MouseEnteredErdCard Evergreen.V58.DuckDb.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V58.DuckDb.DuckDbRef Evergreen.V58.DuckDb.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V58.DuckDb.DuckDbRef Evergreen.V58.DuckDb.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V58.DuckDb.DuckDbRef
    | MouseEnteredErdCardDropdown Evergreen.V58.DuckDb.DuckDbRef
    | MouseLeftErdCardDropdown
    | ClickedErdCardDropdownOption Evergreen.V58.DimensionalModel.DimensionalModelRef Evergreen.V58.DuckDb.DuckDbRef (Evergreen.V58.DimensionalModel.KimballAssignment Evergreen.V58.DuckDb.DuckDbRef_ (List Evergreen.V58.DuckDb.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V58.DuckDb.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event


type alias Model =
    { theme : Evergreen.V58.Ui.ColorTheme
    , dimModel1 : Evergreen.V58.DimensionalModel.DimensionalModel
    , dimModel2 : Evergreen.V58.DimensionalModel.DimensionalModel
    , dimModel3 : Evergreen.V58.DimensionalModel.DimensionalModel
    , dimModel4 : Evergreen.V58.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
