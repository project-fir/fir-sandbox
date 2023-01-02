module Evergreen.V64.Pages.Stories.FirLang exposing (..)

import Dict
import Evergreen.V64.Editor
import Evergreen.V64.FirLang.Lambda.Expression
import Evergreen.V64.Ui


type alias Model =
    { editor : Evergreen.V64.Editor.Editor
    , evalResult : Maybe String
    , environment : Dict.Dict String String
    , theme : Evergreen.V64.Ui.ColorTheme
    , debugStr : Maybe String
    , viewStyle : Evergreen.V64.FirLang.Lambda.Expression.ViewStyle
    , cmdLine : String
    }


type Msg
    = MyEditorMsg Evergreen.V64.Editor.EditorMsg
