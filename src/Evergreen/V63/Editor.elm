module Evergreen.V63.Editor exposing (..)

import Evergreen.V63.EditorModel
import Evergreen.V63.EditorMsg


type Editor
    = Editor Evergreen.V63.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V63.EditorMsg.EMsg
