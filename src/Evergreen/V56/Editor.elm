module Evergreen.V56.Editor exposing (..)

import Evergreen.V56.EditorModel
import Evergreen.V56.EditorMsg


type Editor
    = Editor Evergreen.V56.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V56.EditorMsg.EMsg
