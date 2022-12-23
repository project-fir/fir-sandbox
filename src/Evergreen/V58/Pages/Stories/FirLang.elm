module Evergreen.V58.Pages.Stories.FirLang exposing (..)

import Dict
import Evergreen.V58.Editor
import Evergreen.V58.FirLang.Lambda.Expression
import Evergreen.V58.Ui


type alias Model =
    { editor : Evergreen.V58.Editor.Editor
    , evalResult : Maybe String
    , environment : Dict.Dict String String
    , theme : Evergreen.V58.Ui.ColorTheme
    , debugStr : Maybe String
    , viewStyle : Evergreen.V58.FirLang.Lambda.Expression.ViewStyle
    , cmdLine : String
    }


type Msg
    = MyEditorMsg Evergreen.V58.Editor.EditorMsg
