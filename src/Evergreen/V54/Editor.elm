module Evergreen.V54.Editor exposing (..)

import Evergreen.V54.EditorModel
import Evergreen.V54.EditorMsg


type Editor
    = Editor Evergreen.V54.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V54.EditorMsg.EMsg
