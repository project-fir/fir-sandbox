module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , sharedView
    , subscriptions
    , update
    )

import Element as E exposing (..)
import Request exposing (Request)
import Task
import Time
import Ui exposing (ColorTheme, PaletteName(..), themeOf)
import View exposing (View)



-- INIT


type alias Flags =
    ()


type alias Model =
    { zone : Time.Zone
    , selectedTheme : ColorTheme
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ json =
    ( Model Time.utc (themeOf Nitro)
      -- placeholder gets rewritten on the Task.perform below
    , Task.perform SetTimeZoneToLocale Time.here
    )



-- UPDATE


type Msg
    = SetTimeZoneToLocale Time.Zone
    | Shared__UserSelectedPalette PaletteName


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        SetTimeZoneToLocale newZone ->
            ( { model | zone = newZone }, Cmd.none )

        Shared__UserSelectedPalette palette ->
            ( { model | selectedTheme = themeOf palette }, Cmd.none )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none



-- VIEW


sharedView :
    Request
    -> { page : View msg, toMsg : Msg -> msg }
    -> Model
    -> View msg
sharedView req { page, toMsg } model =
    { title =
        if String.isEmpty page.title then
            "Fir"

        else
            page.title ++ " | Fir"
    , body =
        elements req { page = page, toMsg = toMsg } model
    }


elements : Request -> { page : View msg, toMsg : Msg -> msg } -> Model -> Element msg
elements req { page, toMsg } model =
    el
        [ width fill
        , height fill
        , centerX
        ]
        page.body
