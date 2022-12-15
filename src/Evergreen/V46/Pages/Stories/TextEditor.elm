module Evergreen.V46.Pages.Stories.TextEditor exposing (..)

import Evergreen.V46.Editor


type alias Model =
    { editor : Evergreen.V46.Editor.Editor
    }


type Msg
    = MyEditorMsg Evergreen.V46.Editor.EditorMsg
