module Evergreen.V62.Editor exposing (..)

import Evergreen.V62.EditorModel
import Evergreen.V62.EditorMsg


type Editor
    = Editor Evergreen.V62.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V62.EditorMsg.EMsg
