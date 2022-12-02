module Gen.Params.Stories.EntityRelationshipDiagram exposing (Params, parser)

import Url.Parser as Parser exposing ((</>), Parser)


type alias Params =
    ()


parser =
    (Parser.s "stories" </> Parser.s "entity-relationship-diagram")

