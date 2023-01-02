module Evergreen.V64.Editor exposing (..)

import Evergreen.V64.EditorModel
import Evergreen.V64.EditorMsg


type Editor
    = Editor Evergreen.V64.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V64.EditorMsg.EMsg
