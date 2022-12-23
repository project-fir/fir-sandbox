module Evergreen.V58.Pages.ElmUiSvgIssue exposing (..)


type alias Model =
    { hoveredOnFish : Maybe Int
    , mouseOnCard : Bool
    }


type Msg
    = ReplaceMe
    | MouseEnteredFish Int
    | MouseEnteredCard
    | MouseLeftCard
