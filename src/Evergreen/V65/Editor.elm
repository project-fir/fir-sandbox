module Evergreen.V65.Editor exposing (..)

import Evergreen.V65.EditorModel
import Evergreen.V65.EditorMsg


type Editor
    = Editor Evergreen.V65.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V65.EditorMsg.EMsg
