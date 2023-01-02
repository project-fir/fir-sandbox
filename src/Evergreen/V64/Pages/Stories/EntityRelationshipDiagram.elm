module Evergreen.V64.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V64.DimensionalModel
import Evergreen.V64.FirApi
import Evergreen.V64.Ui
import Html.Events.Extra.Mouse


type Msg
    = MouseEnteredErdCard Evergreen.V64.FirApi.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V64.FirApi.DuckDbRef Evergreen.V64.FirApi.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V64.FirApi.DuckDbRef Evergreen.V64.FirApi.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V64.FirApi.DuckDbRef
    | MouseEnteredErdCardDropdown Evergreen.V64.FirApi.DuckDbRef
    | MouseLeftErdCardDropdown
    | ClickedErdCardDropdownOption Evergreen.V64.DimensionalModel.DimensionalModelRef Evergreen.V64.FirApi.DuckDbRef (Evergreen.V64.DimensionalModel.KimballAssignment Evergreen.V64.FirApi.DuckDbRef_ (List Evergreen.V64.FirApi.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V64.FirApi.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event


type alias Model =
    { theme : Evergreen.V64.Ui.ColorTheme
    , dimModel1 : Evergreen.V64.DimensionalModel.DimensionalModel
    , dimModel2 : Evergreen.V64.DimensionalModel.DimensionalModel
    , dimModel3 : Evergreen.V64.DimensionalModel.DimensionalModel
    , dimModel4 : Evergreen.V64.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
