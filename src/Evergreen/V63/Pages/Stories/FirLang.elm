module Evergreen.V63.Pages.Stories.FirLang exposing (..)

import Dict
import Evergreen.V63.Editor
import Evergreen.V63.FirLang.Lambda.Expression
import Evergreen.V63.Ui


type alias Model =
    { editor : Evergreen.V63.Editor.Editor
    , evalResult : Maybe String
    , environment : Dict.Dict String String
    , theme : Evergreen.V63.Ui.ColorTheme
    , debugStr : Maybe String
    , viewStyle : Evergreen.V63.FirLang.Lambda.Expression.ViewStyle
    , cmdLine : String
    }


type Msg
    = MyEditorMsg Evergreen.V63.Editor.EditorMsg
