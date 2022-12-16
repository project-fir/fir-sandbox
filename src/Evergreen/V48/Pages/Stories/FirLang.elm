module Evergreen.V48.Pages.Stories.FirLang exposing (..)

import Evergreen.V48.Editor


type alias Model =
    { editor : Evergreen.V48.Editor.Editor
    }


type Msg
    = MyEditorMsg Evergreen.V48.Editor.EditorMsg
