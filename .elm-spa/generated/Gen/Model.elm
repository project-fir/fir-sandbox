module Gen.Model exposing (Model(..))

import Gen.Params.Home_
import Gen.Params.Kimball
import Gen.Params.Sheet
import Gen.Params.VegaLite
import Gen.Params.NotFound
import Pages.Home_
import Pages.Kimball
import Pages.Sheet
import Pages.VegaLite
import Pages.NotFound


type Model
    = Redirecting_
    | Home_ Gen.Params.Home_.Params
    | Kimball Gen.Params.Kimball.Params Pages.Kimball.Model
    | Sheet Gen.Params.Sheet.Params Pages.Sheet.Model
    | VegaLite Gen.Params.VegaLite.Params Pages.VegaLite.Model
    | NotFound Gen.Params.NotFound.Params

