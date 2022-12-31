module Evergreen.V62.Pages.Stories.FirLang exposing (..)

import Dict
import Evergreen.V62.Editor
import Evergreen.V62.FirLang.Lambda.Expression
import Evergreen.V62.Ui


type alias Model =
    { editor : Evergreen.V62.Editor.Editor
    , evalResult : Maybe String
    , environment : Dict.Dict String String
    , theme : Evergreen.V62.Ui.ColorTheme
    , debugStr : Maybe String
    , viewStyle : Evergreen.V62.FirLang.Lambda.Expression.ViewStyle
    , cmdLine : String
    }


type Msg
    = MyEditorMsg Evergreen.V62.Editor.EditorMsg
