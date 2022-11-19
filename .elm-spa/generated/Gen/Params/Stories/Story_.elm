module Gen.Params.Stories.Story_ exposing (Params, parser)

import Url.Parser as Parser exposing ((</>), Parser)


type alias Params =
    { story : String }


parser =
    Parser.map Params (Parser.s "stories" </> Parser.string)

