module Evergreen.V61.Editor exposing (..)

import Evergreen.V61.EditorModel
import Evergreen.V61.EditorMsg


type Editor
    = Editor Evergreen.V61.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V61.EditorMsg.EMsg
