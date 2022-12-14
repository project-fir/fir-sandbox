module Pages.Stories.Basics exposing (Model, Msg, page)

import Dict
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
import Shared exposing (Msg(..))
import Ui exposing (ColorTheme, DropDownProps, PaletteName(..), SampleData, TableProps, TableVal(..), button, dropdownMenu, firTable, themeOf)
import Utils exposing (bool2Str)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- INIT


type alias Model =
    { theme : ColorTheme
    , isDrawerOpen : Bool
    , isMenuHovered : Bool
    , hoveredOnOption : Maybe Int
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    ( { theme = shared.selectedTheme
      , isDrawerOpen = False
      , isMenuHovered = False
      , hoveredOnOption = Nothing
      }
    , Effect.none
    )



-- UPDATE


type alias MenuId =
    String


type alias DropDownOptionId =
    Int


type Msg
    = Basics__UserSelectedPalette PaletteName
    | UserToggledDrawer MenuId
    | MouseEnteredDropDownMenu MenuId
    | MouseLeftDropDownMenu
    | MouseEnteredOption Int
    | Noop


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        MouseEnteredOption optionId ->
            ( { model
                | hoveredOnOption = Just optionId
              }
            , Effect.none
            )

        Noop ->
            ( model, Effect.none )

        Basics__UserSelectedPalette paletteName ->
            -- TODO: How can I map this to update Shared.Model?
            ( { model
                | theme = themeOf paletteName
                , isDrawerOpen = False
                , hoveredOnOption = Nothing
              }
            , Effect.none
            )

        UserToggledDrawer menuId ->
            ( { model
                | isDrawerOpen = not model.isDrawerOpen
                , hoveredOnOption = Nothing
              }
            , Effect.none
            )

        MouseEnteredDropDownMenu menuId ->
            ( { model | isMenuHovered = True }
            , Effect.none
            )

        MouseLeftDropDownMenu ->
            ( { model | isMenuHovered = False }, Effect.none )



--( { model | selectedTheme = themeOf paletteName }, Effect.none )
-- SUBSCRIPTIONS


swatchSize =
    100



-- VIEW


view : Model -> View Msg
view model =
    { title = "Basics"
    , body = elements model
    }


data : List SampleData
data =
    [ { task = "abstract this away"
      , isComplete = True
      }
    , { task = "hard code some data"
      , isComplete = True
      }
    , { task = "scrub the tub"
      , isComplete = False
      }
    , { task = "feed Simon"
      , isComplete = True
      }
    ]


elements : Model -> Element Msg
elements model =
    let
        testMenuId : String
        testMenuId =
            "test-menu"

        dropDownProps : DropDownProps Msg MenuId DropDownOptionId
        dropDownProps =
            { isOpen = model.isDrawerOpen
            , id = testMenuId
            , heightPx = 20
            , widthPx = 60
            , onDrawerClick = UserToggledDrawer
            , onMenuMouseEnter = MouseEnteredDropDownMenu
            , onMenuMouseLeave = MouseLeftDropDownMenu
            , isMenuHovered = model.isMenuHovered
            , hoveredOnOption = model.hoveredOnOption
            , menuBarText = "Theme"
            , options =
                Dict.fromList
                    [ ( 0
                      , { displayText = "Coffee Run"
                        , id = 0
                        , onClick = Basics__UserSelectedPalette CoffeeRun
                        , onHover = MouseEnteredOption 0
                        }
                      )
                    , ( 1
                      , { displayText = "Bamboo Beach"
                        , onClick = Basics__UserSelectedPalette BambooBeach
                        , onHover = MouseEnteredOption 1
                        , id = 1
                        }
                      )
                    , ( 2
                      , { displayText = "Nitro"
                        , onClick = Basics__UserSelectedPalette Nitro
                        , onHover = MouseEnteredOption 2
                        , id = 2
                        }
                      )
                    ]
            }

        viewHeader : Element Msg
        viewHeader =
            el
                [ width fill
                , height fill
                , alignLeft
                , Border.widthEach { top = 0, left = 0, right = 0, bottom = 3 }
                , Border.color model.theme.secondary
                , Font.size 24
                ]
            <|
                row [ padding 5, width fill ]
                    [ el [ alignLeft, Font.bold ] (E.text "Basics")
                    , el [ Font.size 14, alignRight ] (dropdownMenu model dropDownProps)
                    ]

        viewSwatch : Color -> String -> Color -> Element Msg
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

        viewThemeSwatches : ColorTheme -> Element Msg
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

        viewCommonSwatches : ColorTheme -> Element Msg
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

        viewDebugSwatches : ColorTheme -> Element Msg
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
    el [ width fill, height fill, Background.color model.theme.deadspace, paddingXY 0 10 ] <|
        el
            [ Font.color model.theme.black
            , Font.size 16
            , width (fill |> minimum 400 |> maximum 800)
            , height fill
            , Background.color model.theme.background
            , centerX
            ]
            (column
                [ width fill
                , centerX
                , spacing 5
                , padding 5
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
                , el [ Font.bold ] (E.text " ")
                , el [ Font.bold ] (E.text "Sample Button:")
                , button model
                    { onClick = Nothing
                    , displayText = "Click Me!"
                    }
                , el [ Font.bold ] (E.text " ")
                , el [ Font.bold ] (E.text "Sample Table:")
                , firTable model tableProps
                ]
            )


tableProps : TableProps
tableProps =
    { dataDict =
        Dict.fromList
            [ ( "task"
              , [ String_ "hard code data"
                , String_ "abstract this away"
                , String_ "scrub the tub"
                , String_ "feed Simon"
                ]
              )
            , ( "is_complete"
              , [ Bool_ True
                , Bool_ True
                , Bool_ False
                , Bool_ True
                ]
              )
            ]
    , tableWidthPx = 150
    }


themeName : PaletteName -> String
themeName name =
    case name of
        BambooBeach ->
            "Bamboo Beach"

        CoffeeRun ->
            "Coffee Run"

        Nitro ->
            "Nitro"
