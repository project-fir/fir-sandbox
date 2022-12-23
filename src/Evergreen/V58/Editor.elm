module Evergreen.V58.Editor exposing (..)

import Evergreen.V58.EditorModel
import Evergreen.V58.EditorMsg


type Editor
    = Editor Evergreen.V58.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V58.EditorMsg.EMsg
