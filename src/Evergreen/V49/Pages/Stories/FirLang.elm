module Evergreen.V49.Pages.Stories.FirLang exposing (..)

import Evergreen.V49.Editor
import Evergreen.V49.Ui


type alias Model =
    { editor : Evergreen.V49.Editor.Editor
    , theme : Evergreen.V49.Ui.ColorTheme
    }


type Msg
    = MyEditorMsg Evergreen.V49.Editor.EditorMsg
