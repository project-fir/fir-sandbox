module Evergreen.V46.Editor exposing (..)

import Evergreen.V46.EditorModel
import Evergreen.V46.EditorMsg


type Editor
    = Editor Evergreen.V46.EditorModel.EditorModel


type alias EditorMsg =
    Evergreen.V46.EditorMsg.EMsg
