module Bridge exposing (..)

import Lamdera


sendToBackend =
    Lamdera.sendToBackend


type ToBackend
    = NoopToBackend
