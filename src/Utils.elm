module Utils exposing (KeyCode, bool2Str, cartesian, collapseWhitespace, keyDecoder, removeNothingsFromList, send)

-- miscellaneous utility functions

import Browser.Navigation as Nav
import Gen.Route as Route exposing (Route)
import Json.Decode as JD
import Regex
import Task
import Url exposing (Url)


removeNothingsFromList : List (Maybe a) -> List a
removeNothingsFromList list =
    List.filterMap identity list


type alias KeyCode =
    String


keyDecoder : JD.Decoder String
keyDecoder =
    JD.field "key" JD.string


send : msg -> Cmd msg
send m =
    Task.succeed m
        |> Task.perform identity


bool2Str : Bool -> String
bool2Str b =
    case b of
        True ->
            "true"

        False ->
            "false"


collapseWhitespace : String -> Bool -> String
collapseWhitespace s trim =
    -- collapses all whitespace chains to a single " "
    -- ex: "  input  \t \n   string" -> " input string"
    case Regex.fromString "\\s+" of
        Nothing ->
            s

        Just rex ->
            case trim of
                True ->
                    String.trim (Regex.replace rex (\_ -> " ") s)

                False ->
                    Regex.replace rex (\_ -> " ") s


cartesian : List a -> List b -> List ( a, b )
cartesian xs ys =
    List.concatMap
        (\x -> List.map (\y -> ( x, y )) ys)
        xs



-- begin region: elm-spa Route


navigate : Nav.Key -> Route -> Cmd msg
navigate key route =
    Nav.pushUrl key (Route.toHref route)


fromUrl : Url -> Route
fromUrl =
    Route.fromUrl



--end region: elm-spa Route
