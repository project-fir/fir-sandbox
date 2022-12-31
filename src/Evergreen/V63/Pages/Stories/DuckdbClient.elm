module Evergreen.V63.Pages.Stories.DuckdbClient exposing (..)

import Browser.Dom
import Evergreen.V63.Editor
import Evergreen.V63.FirApi
import Evergreen.V63.Ui
import Http
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
    { editor : Evergreen.V63.Editor.Editor
    , theme : Evergreen.V63.Ui.ColorTheme
    , viewStatus : ViewStatus
    , firApiStatus : FirApiStatus
    }


type Msg
    = MyEditorMsg Evergreen.V63.Editor.EditorMsg
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
    | Tick_PingFirApi Time.Posix
    | Got_PingResponse Int (Result Http.Error Evergreen.V63.FirApi.PingResponse)
