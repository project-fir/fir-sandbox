module Gen.Params.KimballBasicUi exposing (Params, parser)

import Url.Parser as Parser exposing ((</>), Parser)


type alias Params =
    ()


parser =
    (Parser.s "kimball-basic-ui")

