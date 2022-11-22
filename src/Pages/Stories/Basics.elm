module Pages.Stories.Basics exposing (Model, Msg, page)

import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Stories.Basics exposing (Params)
import Page
import Request
import Shared
import Ui exposing (ColorTheme, PaletteName(..), theme, themeOf)
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
    { selectedTheme : ColorTheme
    }


init : ( Model, Effect Msg )
init =
    ( { selectedTheme = themeOf BambooBeach
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserSelectedPalette PaletteName


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserSelectedPalette paletteName ->
            ( model, Effect.none )



--( { model | selectedTheme = themeOf paletteName }, Effect.none )
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


swatchSize =
    100


viewDropDown : Element msg
viewDropDown =
    E.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Basics"
    , body = elements model
    }


elements : Model -> Element msg
elements model =
    let
        viewHeader : Element msg
        viewHeader =
            el
                [ width fill
                , height fill
                , alignLeft
                , Border.widthEach { top = 0, left = 0, right = 0, bottom = 3 }
                , Border.color theme.secondary
                , Font.size 24
                ]
            <|
                row [ padding 5, width fill ]
                    [ el [ alignLeft, Font.bold ] (E.text "Basics")
                    , el [ Font.size 14, alignRight ] (E.text "TODO: dropdown here -->")
                    , viewDropDown
                    ]

        viewSwatch : Color -> String -> Color -> Element msg
        viewSwatch swatchColor displayText linkColor =
            let
                -- Supply a "real link" without degrading UX by self-linking
                ( selfLink, swatchLinkText ) =
                    ( "/stories/basics", "a self link" )
            in
            column
                [ width (px swatchSize)
                , height (px swatchSize)
                , Background.color swatchColor
                , centerX
                , centerY
                , Font.size 10
                , spacing 5
                ]
                [ el
                    [ centerX
                    , centerY
                    ]
                    (E.text displayText)
                , link
                    [ centerX
                    , centerY
                    , Font.color linkColor
                    ]
                    { url = selfLink
                    , label = text swatchLinkText
                    }
                ]

        viewThemeSwatches : ColorTheme -> Element msg
        viewThemeSwatches theme_ =
            column [ height fill, width fill, padding 5 ]
                [ row
                    [ width fill
                    , height (px (swatchSize + 10))
                    , spacing 25

                    --, Border.width 1
                    --, Border.color theme.debugAlert
                    ]
                    [ viewSwatch theme_.primary1 "Primary 1" theme_.link
                    , viewSwatch theme_.primary2 "Primary 2" theme_.link
                    , viewSwatch theme_.secondary "Secondary" theme_.link
                    , viewSwatch theme_.background "Background" theme_.link
                    , viewSwatch theme_.deadspace "DeadSpace" theme_.link
                    ]
                ]

        viewCommonSwatches : ColorTheme -> Element msg
        viewCommonSwatches theme_ =
            row
                [ height (px (swatchSize + 10))
                , width fill
                , spacing 40
                , centerX
                ]
                [ viewSwatch theme_.white "white" theme_.link
                , viewSwatch theme_.gray "gray" theme_.link
                , viewSwatch theme_.black "black" theme_.link
                ]

        viewDebugSwatches : ColorTheme -> Element msg
        viewDebugSwatches theme_ =
            row
                [ height (px (swatchSize + 10))
                , width fill
                , spacing 60
                ]
                [ viewSwatch theme_.debugWarn "Debug - warn" theme_.link
                , viewSwatch theme_.debugAlert "Debug - alert" theme_.link
                ]
    in
    el
        [ Font.color theme.black
        , Font.size 16
        , width (fill |> minimum 400 |> maximum 800)
        , height fill
        , Background.color theme.background
        , centerX
        ]
        (column
            [ width fill
            , centerX
            , spacing 5
            ]
            [ viewHeader
            , column [ width fill, height fill ]
                [ el [ Font.bold ] (E.text "Theme swatches")
                , column
                    [ width fill
                    , height fill
                    , padding 10
                    , spacing 10
                    ]
                    [ el [ moveDown 5 ] <| E.text (themeName BambooBeach ++ ":")
                    , viewThemeSwatches (themeOf BambooBeach)
                    , el [ moveDown 5 ] <| E.text (themeName CoffeeRun ++ ":")
                    , viewThemeSwatches (themeOf CoffeeRun)
                    , el [ moveDown 5 ] <| E.text (themeName Nitro ++ ":")
                    , viewThemeSwatches (themeOf Nitro)
                    ]
                ]
            , el [ Font.bold ] <| E.text "Common swatches:"
            , viewCommonSwatches (themeOf BambooBeach)
            , el [ Font.bold ] <| E.text "Debug swatches:"
            , viewDebugSwatches (themeOf BambooBeach)
            ]
        )


themeName : PaletteName -> String
themeName name =
    case name of
        BambooBeach ->
            "Bamboo Beach"

        CoffeeRun ->
            "Coffee Run"

        Nitro ->
            "Nitro"
