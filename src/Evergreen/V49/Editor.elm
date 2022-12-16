module Evergreen.V49.Editor exposing (..)

import Evergreen.V49.EditorModel
import Evergreen.V49.EditorMsg


type Editor
    = Editor Evergreen.V49.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V49.EditorMsg.EMsg
