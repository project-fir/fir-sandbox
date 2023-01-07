module Evergreen.V65.Pages.Stories.DuckdbClient exposing (..)

import Browser.Dom
import Evergreen.V65.Editor
import Evergreen.V65.FirApi
import Evergreen.V65.Ui
import Http
import RemoteData
import Time


type alias LayoutInfo =
    { textPanelWidthPx : Float
    , textPanelHeightPx : Float
    , leftNavWidthPct : Int
    , debugNavWidthPct : Int
    , dataTableHeightPct : Int
    }


type ViewStatus
    = AwaitingViewportInfo
    | Ready LayoutInfo


type FirApiStatus
    = AwaitingScaleFromZero Float Int
    | ApiReady Float
    | ExhaustedWaitingPeriod


type alias Model =
    { editor : Evergreen.V65.Editor.Editor
    , theme : Evergreen.V65.Ui.ColorTheme
    , viewStatus : ViewStatus
    , firApiStatus : FirApiStatus
    , duckDbRefs : RemoteData.RemoteData Http.Error (List Evergreen.V65.FirApi.DuckDbRef)
    , duckDbRefInspectionData : RemoteData.RemoteData Http.Error Evergreen.V65.FirApi.DuckDbMetaResponse
    }


type Msg
    = MyEditorMsg Evergreen.V65.Editor.EditorMsg
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | Tick_PingFirApi Time.Posix
    | Got_PingResponse Int (Result Http.Error Evergreen.V65.FirApi.PingResponse)
    | Got_DuckDbRefsResponse (Result Http.Error Evergreen.V65.FirApi.DuckDbRefsResponse)
    | Got_DuckDbMetaDataResponse (Result Http.Error Evergreen.V65.FirApi.DuckDbMetaResponse)
    | UserClickedQueryButton
    | UserClickedDuckDbRefToInspect Evergreen.V65.FirApi.DuckDbRef
