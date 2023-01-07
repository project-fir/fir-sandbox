module Evergreen.V65.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V65.DimensionalModel
import Evergreen.V65.FirApi
import Evergreen.V65.Ui
import Html.Events.Extra.Mouse


type Msg
    = MouseEnteredErdCard Evergreen.V65.FirApi.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V65.FirApi.DuckDbRef Evergreen.V65.FirApi.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V65.FirApi.DuckDbRef Evergreen.V65.FirApi.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V65.FirApi.DuckDbRef
    | MouseEnteredErdCardDropdown Evergreen.V65.FirApi.DuckDbRef
    | MouseLeftErdCardDropdown
    | ClickedErdCardDropdownOption Evergreen.V65.DimensionalModel.DimensionalModelRef Evergreen.V65.FirApi.DuckDbRef (Evergreen.V65.DimensionalModel.KimballAssignment Evergreen.V65.FirApi.DuckDbRef_ (List Evergreen.V65.FirApi.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V65.FirApi.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event


type alias Model =
    { theme : Evergreen.V65.Ui.ColorTheme
    , dimModel1 : Evergreen.V65.DimensionalModel.DimensionalModel
    , dimModel2 : Evergreen.V65.DimensionalModel.DimensionalModel
    , dimModel3 : Evergreen.V65.DimensionalModel.DimensionalModel
    , dimModel4 : Evergreen.V65.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
