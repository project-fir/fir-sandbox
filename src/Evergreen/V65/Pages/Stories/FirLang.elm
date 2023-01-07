module Evergreen.V65.Pages.Stories.FirLang exposing (..)

import Dict
import Evergreen.V65.Editor
import Evergreen.V65.FirLang.Lambda.Expression
import Evergreen.V65.Ui


type alias Model =
    { editor : Evergreen.V65.Editor.Editor
    , evalResult : Maybe String
    , environment : Dict.Dict String String
    , theme : Evergreen.V65.Ui.ColorTheme
    , debugStr : Maybe String
    , viewStyle : Evergreen.V65.FirLang.Lambda.Expression.ViewStyle
    , cmdLine : String
    }


type Msg
    = MyEditorMsg Evergreen.V65.Editor.EditorMsg
