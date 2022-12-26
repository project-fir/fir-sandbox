module Evergreen.V61.Pages.Stories.FirLang exposing (..)

import Dict
import Evergreen.V61.Editor
import Evergreen.V61.FirLang.Lambda.Expression
import Evergreen.V61.Ui


type alias Model =
    { editor : Evergreen.V61.Editor.Editor
    , evalResult : Maybe String
    , environment : Dict.Dict String String
    , theme : Evergreen.V61.Ui.ColorTheme
    , debugStr : Maybe String
    , viewStyle : Evergreen.V61.FirLang.Lambda.Expression.ViewStyle
    , cmdLine : String
    }


type Msg
    = MyEditorMsg Evergreen.V61.Editor.EditorMsg
