module Evergreen.V61.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V61.DimensionalModel
import Evergreen.V61.DuckDb
import Evergreen.V61.Ui
import Html.Events.Extra.Mouse


type Msg
    = MouseEnteredErdCard Evergreen.V61.DuckDb.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V61.DuckDb.DuckDbRef Evergreen.V61.DuckDb.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V61.DuckDb.DuckDbRef Evergreen.V61.DuckDb.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V61.DuckDb.DuckDbRef
    | MouseEnteredErdCardDropdown Evergreen.V61.DuckDb.DuckDbRef
    | MouseLeftErdCardDropdown
    | ClickedErdCardDropdownOption Evergreen.V61.DimensionalModel.DimensionalModelRef Evergreen.V61.DuckDb.DuckDbRef (Evergreen.V61.DimensionalModel.KimballAssignment Evergreen.V61.DuckDb.DuckDbRef_ (List Evergreen.V61.DuckDb.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V61.DuckDb.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event


type alias Model =
    { theme : Evergreen.V61.Ui.ColorTheme
    , dimModel1 : Evergreen.V61.DimensionalModel.DimensionalModel
    , dimModel2 : Evergreen.V61.DimensionalModel.DimensionalModel
    , dimModel3 : Evergreen.V61.DimensionalModel.DimensionalModel
    , dimModel4 : Evergreen.V61.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
