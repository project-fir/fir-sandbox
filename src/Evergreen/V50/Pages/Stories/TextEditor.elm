module Evergreen.V50.Pages.Stories.TextEditor exposing (..)

import Evergreen.V50.Editor


type alias Model =
    { editor : Evergreen.V50.Editor.Editor
    }


type Msg
    = MyEditorMsg Evergreen.V50.Editor.EditorMsg
