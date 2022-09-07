module Gen.Msg exposing (Msg(..))

import Gen.Params.Home_
import Gen.Params.Sheet
import Gen.Params.VegaLite
import Gen.Params.NotFound
import Pages.Home_
import Pages.Sheet
import Pages.VegaLite
import Pages.NotFound


type Msg
    = Sheet Pages.Sheet.Msg
    | VegaLite Pages.VegaLite.Msg

