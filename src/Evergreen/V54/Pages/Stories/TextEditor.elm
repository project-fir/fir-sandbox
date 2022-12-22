module Evergreen.V54.Pages.Stories.TextEditor exposing (..)

import Evergreen.V54.Editor


type alias Model =
    { editor : Evergreen.V54.Editor.Editor
    }


type Msg
    = MyEditorMsg Evergreen.V54.Editor.EditorMsg
