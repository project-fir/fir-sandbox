module Gen.Model exposing (Model(..))

import Gen.Params.Admin
import Gen.Params.Home_
import Gen.Params.Kimball
import Gen.Params.Sheet
import Gen.Params.VegaLite
import Gen.Params.NotFound
import Pages.Admin
import Pages.Home_
import Pages.Kimball
import Pages.Sheet
import Pages.VegaLite
import Pages.NotFound


type Model
    = Redirecting_
    | Admin Gen.Params.Admin.Params Pages.Admin.Model
    | Home_ Gen.Params.Home_.Params
    | Kimball Gen.Params.Kimball.Params Pages.Kimball.Model
    | Sheet Gen.Params.Sheet.Params Pages.Sheet.Model
    | VegaLite Gen.Params.VegaLite.Params Pages.VegaLite.Model
    | NotFound Gen.Params.NotFound.Params

