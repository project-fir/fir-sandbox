module Evergreen.V40.Pages.Stories.EntityRelationshipDiagram exposing (..)

import Dict
import Evergreen.V40.DimensionalModel
import Evergreen.V40.DuckDb
import Evergreen.V40.Ui


type alias Model =
    { theme : Evergreen.V40.Ui.ColorTheme
    , tableInfos : Dict.Dict Evergreen.V40.DuckDb.DuckDbRefString Evergreen.V40.DimensionalModel.DimModelDuckDbSourceInfo
    }


type Msg
    = ReplaceMe
