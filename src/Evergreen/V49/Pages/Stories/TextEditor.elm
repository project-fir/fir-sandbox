module Evergreen.V49.Pages.Stories.TextEditor exposing (..)

import Evergreen.V49.Editor


type alias Model =
    { editor : Evergreen.V49.Editor.Editor
    }


type Msg
    = MyEditorMsg Evergreen.V49.Editor.EditorMsg
