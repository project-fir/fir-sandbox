module Evergreen.V48.Editor exposing (..)

import Evergreen.V48.EditorModel
import Evergreen.V48.EditorMsg


type Editor
    = Editor Evergreen.V48.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V48.EditorMsg.EMsg
