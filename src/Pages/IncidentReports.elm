module Pages.IncidentReports exposing (Model, Msg, page)

import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Gen.Params.IncidentReports exposing (Params)
import Page
import Request
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


init : ( Model, Effect Msg )
init =
    ( {}, Effect.none )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Fir | Incidents"
    , body = viewElements model
    }


viewElements : Model -> Element Msg
viewElements _ =
    el [ width fill, height fill, padding 10 ]
        (textColumn
            [ Font.size 14, width (px 600), centerX, spacing 10 ]
            [ paragraph [] [ E.text """2022-12-22 - Lamdera cache refresh cycle broken for 3 days""" ]
            , paragraph []
                [ E.text """ I could not refresh DuckDB cache in Lamdera backend
            via the /admin page.
            """
                ]
            , paragraph []
                [ E.text """I retraced my steps, and recalled that I added an /images directory
                in fir-api-production bucket, to host a picture of an ant for a snippet I'm working on.
            This bucket is private (which is good), but I forgot. So, I created a public-asset bucket instead.
            I did not clean up the data I left in the fir-api bucket. The call to /duckdb/refs was broken for
            a few days. The Lamdera app was working as expected, but updates to backend cache could not be performed.
            """ ]
            , paragraph [] [ E.text """Lesson here is easy, don't cross wire projects! However, this exposes fragility of
            the JSON-stored-in-gcs hacky solution I went with. Since DuckDB .parquet files are stored on that bucket, I had
             to write GCS boiler plate code anyway, and felt lazy, did not implement a proper database.""" ]
            , paragraph [] [ E.text """
             For source of truth metadata about DuckDB, I really should implement a proper database solution
             See ticket: FIR-70, I outlined some thoughts re: trade-offs of different solutions.
             """ ]
            ]
        )
