module Evergreen.V50.Editor exposing (..)

import Evergreen.V50.EditorModel
import Evergreen.V50.EditorMsg


type Editor
    = Editor Evergreen.V50.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V50.EditorMsg.EMsg
