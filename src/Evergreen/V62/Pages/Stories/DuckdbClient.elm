module Evergreen.V62.Pages.Stories.DuckdbClient exposing (..)

import Browser.Dom
import Evergreen.V62.Editor
import Evergreen.V62.Ui


type alias LayoutInfo =
    { textPanelWidthPx : Float
    , textPanelHeightPx : Float
    , navWidthPct : Int
    , dataTableHeightPct : Int
    }


type ViewStatus
    = AwaitingViewportInfo
    | Ready LayoutInfo


type alias Model =
    { editor : Evergreen.V62.Editor.Editor
    , theme : Evergreen.V62.Ui.ColorTheme
    , viewStatus : ViewStatus
    }


type Msg
    = MyEditorMsg Evergreen.V62.Editor.EditorMsg
    | GotViewport Browser.Dom.Viewport
    | GotResizeEvent Int Int
