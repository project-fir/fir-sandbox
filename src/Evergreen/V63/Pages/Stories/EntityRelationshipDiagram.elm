module Evergreen.V63.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Evergreen.V63.DimensionalModel
import Evergreen.V63.FirApi
import Evergreen.V63.Ui
import Html.Events.Extra.Mouse


type Msg
    = MouseEnteredErdCard Evergreen.V63.FirApi.DuckDbRef
    | MouseLeftErdCard
    | MouseEnteredErdCardColumnRow Evergreen.V63.FirApi.DuckDbRef Evergreen.V63.FirApi.DuckDbColumnDescription
    | ClickedErdCardColumnRow Evergreen.V63.FirApi.DuckDbRef Evergreen.V63.FirApi.DuckDbColumnDescription
    | ToggledErdCardDropdown Evergreen.V63.FirApi.DuckDbRef
    | MouseEnteredErdCardDropdown Evergreen.V63.FirApi.DuckDbRef
    | MouseLeftErdCardDropdown
    | ClickedErdCardDropdownOption Evergreen.V63.DimensionalModel.DimensionalModelRef Evergreen.V63.FirApi.DuckDbRef (Evergreen.V63.DimensionalModel.KimballAssignment Evergreen.V63.FirApi.DuckDbRef_ (List Evergreen.V63.FirApi.DuckDbColumnDescription))
    | BeginErdCardDrag Evergreen.V63.FirApi.DuckDbRef
    | ContinueErdCardDrag Html.Events.Extra.Mouse.Event
    | ErdCardDragStopped Html.Events.Extra.Mouse.Event


type alias Model =
    { theme : Evergreen.V63.Ui.ColorTheme
    , dimModel1 : Evergreen.V63.DimensionalModel.DimensionalModel
    , dimModel2 : Evergreen.V63.DimensionalModel.DimensionalModel
    , dimModel3 : Evergreen.V63.DimensionalModel.DimensionalModel
    , dimModel4 : Evergreen.V63.DimensionalModel.DimensionalModel
    , msgHistory : List Msg
    , isDummyDrawerOpen : Bool
    }
