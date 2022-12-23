module Evergreen.V56.Pages.Stories.TextEditor exposing (..)

import Evergreen.V56.Editor


type alias Model =
    { editor : Evergreen.V56.Editor.Editor
    }


type Msg
    = MyEditorMsg Evergreen.V56.Editor.EditorMsg
