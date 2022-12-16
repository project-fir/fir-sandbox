module Evergreen.V52.Pages.Stories.TextEditor exposing (..)

import Evergreen.V52.Editor


type alias Model =
    { editor : Evergreen.V52.Editor.Editor
    }


type Msg
    = MyEditorMsg Evergreen.V52.Editor.EditorMsg
