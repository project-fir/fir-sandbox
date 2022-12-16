module Evergreen.V52.Editor exposing (..)

import Evergreen.V52.EditorModel
import Evergreen.V52.EditorMsg


type Editor
    = Editor Evergreen.V52.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V52.EditorMsg.EMsg
