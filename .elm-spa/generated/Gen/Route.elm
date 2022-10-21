module Gen.Route exposing
    ( Route(..)
    , fromUrl
    , toHref
    )

import Gen.Params.Admin
import Gen.Params.ElmUiSvgIssue
import Gen.Params.Home_
import Gen.Params.Kimball
import Gen.Params.Sheet
import Gen.Params.VegaLite
import Gen.Params.NotFound
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Admin
    | ElmUiSvgIssue
    | Home_
    | Kimball
    | Sheet
    | VegaLite
    | NotFound


fromUrl : Url -> Route
fromUrl =
    Parser.parse (Parser.oneOf routes) >> Maybe.withDefault NotFound


routes : List (Parser (Route -> a) a)
routes =
    [ Parser.map Home_ Gen.Params.Home_.parser
    , Parser.map Admin Gen.Params.Admin.parser
    , Parser.map ElmUiSvgIssue Gen.Params.ElmUiSvgIssue.parser
    , Parser.map Kimball Gen.Params.Kimball.parser
    , Parser.map Sheet Gen.Params.Sheet.parser
    , Parser.map VegaLite Gen.Params.VegaLite.parser
    , Parser.map NotFound Gen.Params.NotFound.parser
    ]


toHref : Route -> String
toHref route =
    let
        joinAsHref : List String -> String
        joinAsHref segments =
            "/" ++ String.join "/" segments
    in
    case route of
        Admin ->
            joinAsHref [ "admin" ]
    
        ElmUiSvgIssue ->
            joinAsHref [ "elm-ui-svg-issue" ]
    
        Home_ ->
            joinAsHref []
    
        Kimball ->
            joinAsHref [ "kimball" ]
    
        Sheet ->
            joinAsHref [ "sheet" ]
    
        VegaLite ->
            joinAsHref [ "vega-lite" ]
    
        NotFound ->
            joinAsHref [ "not-found" ]

