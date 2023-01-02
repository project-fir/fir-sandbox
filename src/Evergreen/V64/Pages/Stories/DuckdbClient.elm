module Evergreen.V64.Pages.Stories.DuckdbClient exposing (..)

import Browser.Dom
import Evergreen.V64.Editor
import Evergreen.V64.FirApi
import Evergreen.V64.Ui
import Http
import RemoteData
import Time


type alias LayoutInfo =
    { textPanelWidthPx : Float
    , textPanelHeightPx : Float
    , navWidthPct : Int
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
    { editor : Evergreen.V64.Editor.Editor
    , theme : Evergreen.V64.Ui.ColorTheme
    , viewStatus : ViewStatus
    , firApiStatus : FirApiStatus
    , duckDbRefs : RemoteData.RemoteData Http.Error (List Evergreen.V64.FirApi.DuckDbRef)
    }


type Msg
    = MyEditorMsg Evergreen.V64.Editor.EditorMsg
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | Tick_PingFirApi Time.Posix
    | Got_PingResponse Int (Result Http.Error Evergreen.V64.FirApi.PingResponse)
    | Got_DuckDbRefsResponse (Result Http.Error Evergreen.V64.FirApi.DuckDbRefsResponse)
    | UserClickedQueryButton
