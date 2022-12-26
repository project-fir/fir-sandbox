module Evergreen.V61.Pages.Stories.TextEditor exposing (..)

import Evergreen.V61.Editor


type alias Model =
    { editor : Evergreen.V61.Editor.Editor
    }


type Msg
    = MyEditorMsg Evergreen.V61.Editor.EditorMsg
