module Evergreen.V58.Pages.Stories.TextEditor exposing (..)

import Evergreen.V58.Editor


type alias Model =
    { editor : Evergreen.V58.Editor.Editor
    }


type Msg
    = MyEditorMsg Evergreen.V58.Editor.EditorMsg
