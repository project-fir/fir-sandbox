module Evergreen.V56.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V56.DimensionalModel
import Evergreen.V56.DuckDb
import Evergreen.V56.Ui
import Html.Events.Extra.Mouse


type Msg
    = MouseEnteredErdCard Evergreen.V56.DuckDb.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V56.DuckDb.DuckDbRef Evergreen.V56.DuckDb.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V56.DuckDb.DuckDbRef Evergreen.V56.DuckDb.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V56.DuckDb.DuckDbRef
    | MouseEnteredErdCardDropdown Evergreen.V56.DuckDb.DuckDbRef
    | MouseLeftErdCardDropdown
    | ClickedErdCardDropdownOption Evergreen.V56.DimensionalModel.DimensionalModelRef Evergreen.V56.DuckDb.DuckDbRef (Evergreen.V56.DimensionalModel.KimballAssignment Evergreen.V56.DuckDb.DuckDbRef_ (List Evergreen.V56.DuckDb.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V56.DuckDb.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event


type alias Model =
    { theme : Evergreen.V56.Ui.ColorTheme
    , dimModel1 : Evergreen.V56.DimensionalModel.DimensionalModel
    , dimModel2 : Evergreen.V56.DimensionalModel.DimensionalModel
    , dimModel3 : Evergreen.V56.DimensionalModel.DimensionalModel
    , dimModel4 : Evergreen.V56.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
