module Pages.VegaLite exposing (Model, Msg, page)

import Dict exposing (Dict)
import Effect exposing (Effect)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import FirApi
    exposing
        ( ColumnName
        , DuckDbColumnDescription
        , DuckDbMetaResponse
        , fetchDuckDbTableRefs
        , fetchMetaDataForRef
        , queryDuckDb
        , refToString
        )
import Gen.Params.VegaLite exposing (Params)
import Html.Attributes as HA
import Http exposing (Error(..))
import Page
import QueryBuilder exposing (Aggregation(..), ColumnRef, Granularity(..), KimballColumn(..), TimeClass(..), aggToStr, kimballClassificationToString, queryBuilder)
import RemoteData exposing (RemoteData(..), WebData)
import Request
import Shared
import Ui exposing (theme)
import Utils exposing (removeNothingsFromList)
import VegaUtils exposing (ColumnParamed, mapColToFloatCol, mapColToIntegerCol)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Position
    = Up
    | Middle
    | Down



-- INIT


type alias Model =
    { --spec : Maybe VL.Spec
      duckDbForPlotResponse : WebData FirApi.DuckDbQueryResponse
    , duckDbMetaResponse : WebData FirApi.DuckDbMetaResponse
    , duckDbTableRefs : WebData FirApi.DuckDbRefsResponse
    , selectedTableRef : Maybe FirApi.DuckDbRef
    , hoveredOnTableRef : Maybe FirApi.DuckDbRef

    --, dragDrop : DragDrop.Model Int Position
    , data : { count : Int, position : Position }
    , selectedColumns : Dict ColumnRef KimballColumn
    , kimballCols : List KimballColumn
    , openedDropDown : Maybe ColumnRef
    }


type alias DragId =
    String


type alias DropId =
    String


init : ( Model, Effect Msg )
init =
    ( { --spec = Nothing
        duckDbForPlotResponse = NotAsked
      , duckDbMetaResponse = NotAsked
      , duckDbTableRefs = Loading -- Must also fetch table refs below
      , selectedTableRef = Nothing
      , hoveredOnTableRef = Nothing

      --, dragDrop = DragDrop.init
      , data = { count = 1, position = Middle }
      , selectedColumns = Dict.empty
      , kimballCols = []
      , openedDropDown = Nothing
      }
    , Effect.fromCmd <| fetchDuckDbTableRefs GotDuckDbTableRefsResponse
    )



-- UPDATE
--


type Msg
    = FetchPlotData
      --| RenderPlot
    | FetchTableRefs
    | FetchMetaDataForRef FirApi.DuckDbRef
    | GotDuckDbResponse (Result Http.Error FirApi.DuckDbQueryResponse)
    | GotDuckDbMetaResponse (Result Http.Error FirApi.DuckDbMetaResponse)
    | GotDuckDbTableRefsResponse (Result Http.Error FirApi.DuckDbRefsResponse)
    | UserSelectedTableRef FirApi.DuckDbRef
    | UserMouseEnteredTableRef FirApi.DuckDbRef
    | UserMouseLeftTableRef
      --| DragDropMsg (DragDrop.Msg Int Position)
    | UserClickKimballColumnTab KimballColumn
    | DropDownToggled ColumnRef
    | DropDownSelected_Time ColumnRef TimeClass
    | DropDownSelected_Agg ColumnRef Aggregation


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        DropDownToggled colRef ->
            ( { model
                | openedDropDown =
                    case model.openedDropDown of
                        Nothing ->
                            Just colRef

                        Just _ ->
                            Nothing
              }
            , Effect.none
            )

        DropDownSelected_Agg colRef agg ->
            let
                updatedSelectedCols =
                    Dict.insert colRef (Measure agg colRef) model.selectedColumns
            in
            ( { model
                | openedDropDown = Nothing
                , selectedColumns = updatedSelectedCols
              }
            , Effect.none
            )

        DropDownSelected_Time colRef timeClass ->
            let
                updatedSelectedCols =
                    Dict.insert colRef (Time timeClass colRef) model.selectedColumns
            in
            ( { model
                | openedDropDown = Nothing
                , selectedColumns = updatedSelectedCols
              }
            , Effect.none
            )

        UserClickKimballColumnTab kc ->
            let
                key : ColumnRef
                key =
                    case kc of
                        Dimension colRef ->
                            colRef

                        Measure _ colRef ->
                            colRef

                        Time _ colRef ->
                            colRef

                        Error colRef ->
                            colRef

                updatedSelectedCols : Dict ColumnRef KimballColumn
                updatedSelectedCols =
                    case Dict.member key model.selectedColumns of
                        True ->
                            Dict.remove key model.selectedColumns

                        False ->
                            Dict.insert key kc model.selectedColumns
            in
            ( { model | selectedColumns = updatedSelectedCols }, Effect.none )

        --DragDropMsg msg_ ->
        --    let
        --        ( model_, result ) =
        --            DragDrop.update msg_ model.dragDrop
        --    in
        --    ( { model
        --        | dragDrop = model_
        --        , data =
        --            case result of
        --                Nothing ->
        --                    model.data
        --
        --                Just ( count, position, _ ) ->
        --                    { count = count + 1, position = position }
        --      }
        --    , Effect.fromCmd
        --        (DragDrop.getDragstartEvent msg_
        --            |> Maybe.map (.event >> dragStart)
        --            |> Maybe.withDefault Cmd.none
        --        )
        --    )
        FetchTableRefs ->
            ( { model | duckDbTableRefs = Loading }, Effect.fromCmd <| fetchDuckDbTableRefs GotDuckDbTableRefsResponse )

        GotDuckDbTableRefsResponse response ->
            case response of
                Ok refs ->
                    ( { model | duckDbTableRefs = Success refs }, Effect.none )

                Err err ->
                    ( { model | duckDbTableRefs = Failure err }, Effect.none )

        FetchMetaDataForRef ref ->
            ( { model | duckDbTableRefs = Loading }, Effect.fromCmd <| fetchMetaDataForRef ref GotDuckDbMetaResponse )

        GotDuckDbMetaResponse response ->
            case response of
                Ok data ->
                    let
                        kimballCols : List KimballColumn
                        kimballCols =
                            List.map (\cd -> mapToKimball cd) data.columnDescriptions
                    in
                    ( { model
                        | duckDbMetaResponse = Success data
                        , kimballCols = kimballCols
                      }
                    , Effect.none
                    )

                Err err ->
                    ( { model | duckDbMetaResponse = Failure err }, Effect.none )

        FetchPlotData ->
            let
                queryStr =
                    """TODO: Need to rethink default UX
                """
            in
            ( model, Effect.fromCmd <| queryDuckDb queryStr True [] GotDuckDbResponse )

        GotDuckDbResponse response ->
            case response of
                Ok data ->
                    ( { model
                        | duckDbForPlotResponse = Success data
                      }
                    , Effect.none
                    )

                Err err ->
                    ( { model | duckDbForPlotResponse = Failure err }, Effect.none )

        --RenderPlot ->
        --    let
        --        newSpec =
        --            computeSpec model
        --
        --        elmToJsCmd =
        --            case newSpec of
        --                Nothing ->
        --                    Cmd.none
        --
        --                Just spec ->
        --                    elmToJS spec
        --    in
        --    ( { model | spec = newSpec }, Effect.fromCmd elmToJsCmd )
        UserSelectedTableRef ref ->
            let
                -- NB: A bit hacky, but we submit a query with limit 0, and use the same response without vals
                queryStr =
                    "select * from " ++ refToString ref ++ " limit 0"
            in
            ( { model | duckDbMetaResponse = Loading, selectedTableRef = Just ref }
            , Effect.fromCmd <| fetchMetaDataForRef ref GotDuckDbMetaResponse
            )

        UserMouseEnteredTableRef ref ->
            ( { model | hoveredOnTableRef = Just ref }, Effect.none )

        UserMouseLeftTableRef ->
            ( { model | hoveredOnTableRef = Nothing }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- begin region view


view : Model -> View Msg
view model =
    let
        title =
            "VegaLite Demo"
    in
    { title = title
    , body =
        elements model
    }


elements : Model -> Element Msg
elements model =
    let
        vegaLiteDiv =
            el
                [ htmlAttribute <| HA.id "elm-ui-viz"
                , Border.color theme.secondary
                , Border.width 1
                , width fill
                , height fill
                ]
                E.none
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ height fill
            , width <| fillPortion 8
            , padding 5
            , clipX
            , scrollbarX
            ]
            [ el
                [ width <| fill
                , height <| fillPortion 4
                , clipY
                , scrollbarY
                , Border.width 1
                , Border.color theme.secondary
                ]
                (viewColumnPickerPanel model)
            , row
                [ height <| fillPortion 6
                , width fill
                , clipY
                , scrollbarY
                ]
                [ el
                    [ width <| fillPortion 5
                    , height fill
                    , Border.width 1
                    , Border.color theme.secondary
                    ]
                    (el [ height fill, width <| fillPortion 5 ] (viewDropZone model))

                --(viewPlotPanel model)
                , el [ height fill, width <| fillPortion 5 ] (viewQueryBuilderOutput model)
                ]
            ]
        , el
            [ height fill
            , width <| fillPortion 2
            , Border.width 1
            , Border.color theme.secondary
            , padding 5
            ]
            (viewTableRefs model)
        ]


viewDropZone : Model -> Element Msg
viewDropZone model =
    let
        viewKimballColTab : KimballColumn -> Element Msg
        viewKimballColTab kCol =
            case kCol of
                Dimension colRef ->
                    column
                        [ Background.color <| colorAssociatedWith kCol
                        , width (px 150)
                        , height (px 50)
                        , spaceEvenly
                        , padding 5
                        ]
                        [ E.text colRef
                        , row
                            [ Border.width 1
                            , Border.color theme.secondary
                            , padding 2
                            ]
                            [ E.text <| kimballClassificationToString kCol
                            ]
                        ]

                Measure agg colRef ->
                    let
                        dropdownTimeSelector : Element Msg
                        dropdownTimeSelector =
                            let
                                defaultElements : Element Msg
                                defaultElements =
                                    el [ onClick (DropDownToggled colRef) ] (E.text "???")
                            in
                            el
                                [ Border.width 1
                                , Border.color theme.secondary
                                , padding 2

                                --, inFront
                                ]
                                (case model.openedDropDown of
                                    Nothing ->
                                        defaultElements

                                    Just colRef_ ->
                                        if colRef == colRef_ then
                                            el
                                                [ E.onRight
                                                    (column
                                                        [ Border.color theme.secondary
                                                        , Border.width 1
                                                        , Background.color theme.background
                                                        , spacing 3
                                                        ]
                                                        [ el [ onClick (DropDownSelected_Agg colRef_ Sum) ] <| E.text "Sum"
                                                        , el [ onClick (DropDownSelected_Agg colRef_ Mean) ] <| E.text "Avg"
                                                        , el [ onClick (DropDownSelected_Agg colRef_ Median) ] <| E.text "Median"
                                                        , el [ onClick (DropDownSelected_Agg colRef_ Min) ] <| E.text "Min"
                                                        , el [ onClick (DropDownSelected_Agg colRef_ Max) ] <| E.text "Max"
                                                        , el [ onClick (DropDownSelected_Agg colRef_ Count) ] <| E.text "Count"
                                                        , el [ onClick (DropDownSelected_Agg colRef_ CountDistinct) ] <| E.text "Count (distinct)"
                                                        ]
                                                    )
                                                ]
                                                (el [ onClick (DropDownToggled colRef) ] <| E.text "???")

                                        else
                                            defaultElements
                                )
                    in
                    column
                        [ Background.color <| colorAssociatedWith kCol
                        , width (px 150)
                        , height (px 50)
                        , spaceEvenly
                        , padding 5
                        ]
                        [ E.text colRef
                        , row
                            [ Border.width 1
                            , Border.color theme.secondary
                            , padding 2
                            ]
                            [ E.text <| (kimballClassificationToString kCol ++ " - " ++ aggToStr agg)
                            , dropdownTimeSelector
                            ]
                        ]

                Time tClass colRef ->
                    let
                        timeClassToStr : String
                        timeClassToStr =
                            case tClass of
                                Continuous ->
                                    "Continuous"

                                Discrete granularity ->
                                    case granularity of
                                        Year ->
                                            "Discrete - Year"

                                        Quarter ->
                                            "Discrete - Quarter"

                                        Month ->
                                            "Discrete - Month"

                                        Week ->
                                            "Discrete - Week"

                                        Day ->
                                            "Discrete - Day"

                                        Hour ->
                                            "Discrete - Hour"

                                        Minute ->
                                            "Discrete - Minute"

                        dropdownTimeSelector : Element Msg
                        dropdownTimeSelector =
                            let
                                defaultElements : Element Msg
                                defaultElements =
                                    el [ onClick (DropDownToggled colRef) ] (E.text "???")
                            in
                            el
                                [ Border.width 1
                                , Border.color theme.secondary
                                , padding 2

                                --, inFront
                                ]
                                (case model.openedDropDown of
                                    Nothing ->
                                        defaultElements

                                    Just colRef_ ->
                                        if colRef == colRef_ then
                                            el
                                                [ E.onRight
                                                    (column
                                                        [ Border.color theme.secondary
                                                        , Border.width 1
                                                        , Background.color theme.background
                                                        , spacing 3
                                                        ]
                                                        [ el [ onClick (DropDownToggled colRef) ] (E.text "???")
                                                        , el [ onClick (DropDownSelected_Time colRef_ Continuous) ] <| E.text "Continuous"
                                                        , el [ onClick (DropDownSelected_Time colRef_ (Discrete Year)) ] <| E.text "Discrete - Year"
                                                        , el [ onClick (DropDownSelected_Time colRef_ (Discrete Quarter)) ] <| E.text "Discrete - Quarter"
                                                        , el [ onClick (DropDownSelected_Time colRef_ (Discrete Month)) ] <| E.text "Discrete - Month"
                                                        , el [ onClick (DropDownSelected_Time colRef_ (Discrete Week)) ] <| E.text "Discrete - Week"
                                                        , el [ onClick (DropDownSelected_Time colRef_ (Discrete Day)) ] <| E.text "Discrete - Day"
                                                        , el [ onClick (DropDownSelected_Time colRef_ (Discrete Hour)) ] <| E.text "Discrete - Hour"
                                                        , el [ onClick (DropDownSelected_Time colRef_ (Discrete Minute)) ] <| E.text "Discrete - Minute"
                                                        ]
                                                    )
                                                ]
                                                (el [ onClick <| DropDownToggled colRef_ ] (E.text "???"))

                                        else
                                            defaultElements
                                )
                    in
                    column
                        [ Background.color <| colorAssociatedWith kCol
                        , width (px 150)
                        , height (px 50)
                        , spaceEvenly
                        , padding 5
                        ]
                        [ E.text colRef
                        , row
                            [ Border.width 1
                            , Border.color theme.secondary
                            , padding 2
                            ]
                            [ E.text <| (kimballClassificationToString kCol ++ " - " ++ timeClassToStr)
                            , dropdownTimeSelector
                            ]
                        ]

                Error _ ->
                    E.text <| kimballClassificationToString kCol
    in
    column
        [ spacing 5
        , Border.color theme.secondary
        , Border.width 1
        ]
        (Dict.values
            (Dict.map (\_ kc -> viewKimballColTab kc) model.selectedColumns)
        )


viewQueryBuilderOutput : Model -> Element Msg
viewQueryBuilderOutput model =
    let
        displayText : String
        displayText =
            let
                defaultMessage =
                    "Select a table and some columns to start query building!"
            in
            case model.selectedTableRef of
                Nothing ->
                    defaultMessage

                Just tRef ->
                    case Dict.size model.selectedColumns of
                        0 ->
                            defaultMessage

                        _ ->
                            queryBuilder (Dict.values model.selectedColumns) tRef
    in
    paragraph [ width fill, height fill ] [ text displayText ]


mapToKimball : DuckDbColumnDescription -> KimballColumn
mapToKimball r =
    -- TODO: this function serves to be placeholder logic in lieu of persisting Kimball metadata
    --       upon successful loading of a DuckDB Ref, columns will be mapped in a "best guess" manner
    --       this longer term intent is for this to be a 'first pass', when persisted meta data does not exist
    --       (which should be the case when a user is first using data!). Any user interventions should be
    --       persisted server-side
    let
        mapDataType : { r | dataType : String, name : ColumnName } -> KimballColumn
        mapDataType colDesc =
            case colDesc.dataType of
                "VARCHAR" ->
                    Dimension colDesc.name

                "DATE" ->
                    Time (Discrete Day) colDesc.name

                "TIMESTAMP" ->
                    Time Continuous colDesc.name

                "BOOLEAN" ->
                    Dimension colDesc.name

                "INTEGER" ->
                    Measure Sum colDesc.name

                "HUGEINT" ->
                    Measure Sum colDesc.name

                "BIGINT" ->
                    Measure Sum colDesc.name

                "DOUBLE" ->
                    Measure Sum colDesc.name

                _ ->
                    Error colDesc.name
    in
    mapDataType r


colorAssociatedWith : KimballColumn -> E.Color
colorAssociatedWith kc =
    case kc of
        Dimension _ ->
            theme.primary2

        Measure _ _ ->
            theme.primary1

        Time _ _ ->
            -- TODO: Is time a "big enough" concept to warrant its own color?
            theme.debugWarn

        Error _ ->
            theme.debugAlert


viewColumnPickerPanel : Model -> Element Msg
viewColumnPickerPanel model =
    case model.duckDbMetaResponse of
        NotAsked ->
            el [] (text "Select a table to plot from the right nav")

        Loading ->
            el [] (text "Loading")

        Success data ->
            let
                dimCols : List KimballColumn -> List KimballColumn
                dimCols cols =
                    List.filter
                        (\kc ->
                            case kc of
                                Dimension _ ->
                                    True

                                _ ->
                                    False
                        )
                        cols

                timeCols : List KimballColumn -> List KimballColumn
                timeCols cols =
                    List.filter
                        (\kc ->
                            case kc of
                                Time _ _ ->
                                    True

                                _ ->
                                    False
                        )
                        cols

                measureCols : List KimballColumn -> List KimballColumn
                measureCols cols =
                    List.filter
                        (\kc ->
                            case kc of
                                Measure _ _ ->
                                    True

                                _ ->
                                    False
                        )
                        cols

                errorCols : List KimballColumn -> List KimballColumn
                errorCols cols =
                    List.filter
                        (\kc ->
                            case kc of
                                Error _ ->
                                    True

                                _ ->
                                    False
                        )
                        cols

                viewKimballColTab : KimballColumn -> Element Msg
                viewKimballColTab kc =
                    -- TODO: leaving this logic here for now, but starting to think that this may belong in the update
                    --       function, as a sort-of pre-computed field
                    let
                        ( nameText, typeText ) =
                            case kc of
                                Dimension colRef ->
                                    ( colRef, kimballClassificationToString kc )

                                Measure _ colRef ->
                                    ( colRef, kimballClassificationToString kc )

                                Time _ colRef ->
                                    ( colRef, kimballClassificationToString kc )

                                Error colRef ->
                                    ( colRef, kimballClassificationToString kc )
                    in
                    column
                        [ Border.width 1
                        , Border.color theme.secondary
                        , spacing 15
                        , padding 5
                        , Background.color <| colorAssociatedWith kc
                        , onClick (UserClickKimballColumnTab kc)
                        ]
                        [ text nameText
                        , text typeText
                        ]
            in
            row
                [ spacing 10
                ]
                [ column
                    [ alignTop
                    , width fill
                    , Border.width 1
                    , Border.color theme.secondary
                    ]
                    [ text "Dimensions:"
                    , wrappedRow [] <| List.map (\col -> viewKimballColTab col) (dimCols model.kimballCols)
                    ]
                , column
                    [ alignTop
                    , width fill
                    , Border.width 1
                    , Border.color theme.secondary
                    ]
                    [ text "Time:"
                    , wrappedRow [] <| List.map (\col -> viewKimballColTab col) (timeCols model.kimballCols)
                    ]
                , column
                    [ alignTop
                    , width fill
                    , Border.width 1
                    , Border.color theme.secondary
                    ]
                    [ text "Measures:"
                    , wrappedRow [] <| List.map (\col -> viewKimballColTab col) (measureCols model.kimballCols)
                    ]
                , column
                    [ alignTop
                    , width fill
                    , Border.width 1
                    , Border.color theme.secondary
                    ]
                    [ text "Errors:"
                    , wrappedRow [] <| List.map (\col -> viewKimballColTab col) (errorCols model.kimballCols)
                    ]
                ]

        Failure err ->
            let
                errAttrs =
                    el
                        [ Background.color theme.background
                        , Border.width 2
                        , Border.color theme.secondary
                        ]
            in
            case err of
                BadUrl url ->
                    errAttrs <| text <| "Bad url: " ++ url

                Timeout ->
                    errAttrs <| text <| "Request timed out!"

                BadStatus int ->
                    errAttrs <| text <| "Http status: " ++ String.fromInt int

                NetworkError ->
                    errAttrs <| text <| "An unknown network error!"

                BadBody s ->
                    errAttrs <| text <| "Bad body: " ++ s


viewPlotPanel : Model -> Element Msg
viewPlotPanel model =
    let
        viewDragDropElements : Model -> Element Msg
        viewDragDropElements model_ =
            column
                [ width fill
                , height fill
                ]
                [ viewDiv Up model_.data
                , viewDiv Middle model_.data
                , viewDiv Down model_.data
                ]

        viewDiv : Position -> { count : Int, position : Position } -> Element Msg
        viewDiv position data =
            let
                droppableAttrs : List (Attribute Msg)
                droppableAttrs =
                    if data.position /= position then
                        --List.map E.htmlAttribute (DragDrop.droppable DragDropMsg position)
                        []

                    else
                        []
            in
            el
                ([ width fill
                 , height fill
                 , Border.color theme.secondary
                 , Border.width 5
                 ]
                    ++ droppableAttrs
                )
                (if data.position == position then
                    column
                        [ width fill
                        , height fill
                        ]
                        [ image
                            ([ width (px 200)
                             , height (px 200)
                             , centerX
                             , centerY
                             ]
                             --++ List.map E.htmlAttribute (DragDrop.draggable DragDropMsg data.count)
                            )
                            { src = "https://upload.wikimedia.org/wikipedia/commons/f/f3/Elm_logo.svg"
                            , description = "Elm logo (placeholder)"
                            }
                        , el [ centerX, centerY ] <| E.text (String.fromInt data.count)
                        ]

                 else
                    E.none
                )
    in
    el
        [ width (px 800)
        , height (px 800)
        ]
        (viewDragDropElements model)


viewTableRefs : Model -> Element Msg
viewTableRefs model =
    case model.duckDbTableRefs of
        NotAsked ->
            text "Didn't request data yet"

        Loading ->
            text "Fetching..."

        Success refsResponse ->
            let
                refsSelector : List FirApi.DuckDbRef -> Element Msg
                refsSelector refs =
                    let
                        backgroundColorFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    theme.background

                                Just ref_ ->
                                    if ref == ref_ then
                                        theme.primary1

                                    else
                                        theme.background

                        borderColorFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    theme.background

                                Just ref_ ->
                                    if ref == ref_ then
                                        theme.primary1

                                    else
                                        theme.background

                        borderFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    { top = 1, left = 0, right = 0, bottom = 1 }

                                Just ref_ ->
                                    if ref == ref_ then
                                        { top = 1, left = 0, right = 0, bottom = 1 }

                                    else
                                        { top = 1, left = 0, right = 0, bottom = 1 }

                        innerBlobColorFor ref =
                            case model.hoveredOnTableRef of
                                Nothing ->
                                    theme.background

                                Just ref_ ->
                                    if ref == ref_ then
                                        theme.primary1

                                    else
                                        theme.background

                        ui : FirApi.DuckDbRef -> Element Msg
                        ui ref =
                            row
                                [ width E.fill
                                , paddingXY 0 2
                                , spacingXY 2 0
                                , onClick <| UserSelectedTableRef ref
                                , onMouseEnter <| UserMouseEnteredTableRef ref
                                , onMouseLeave <| UserMouseLeftTableRef
                                , Background.color (backgroundColorFor ref)
                                , Border.widthEach (borderFor ref)
                                , Border.color (borderColorFor ref)
                                ]
                                [ el
                                    [ width <| px 5
                                    , height <| px 5
                                    , Border.width 1
                                    , Background.color (innerBlobColorFor ref)
                                    ]
                                    E.none
                                , text <| refToString ref
                                ]
                    in
                    column
                        [ width E.fill
                        , height E.fill
                        , paddingXY 5 0
                        ]
                    <|
                        List.map (\ref -> ui ref) refs
            in
            column
                [ width E.fill
                , height E.fill
                , spacing 2
                ]
                [ text "DuckDB Refs:"
                , refsSelector refsResponse.refs
                ]

        Failure err ->
            text "Error"



-- end region view
-- begin region vega-lite
--computeSpec : Model -> Maybe VL.Spec
--computeSpec model =
--    let
--        spec0 : ColumnParamed Int -> ColumnParamed Float -> VL.Spec
--        spec0 col1 col2 =
--            let
--                data =
--                    VL.dataFromColumns []
--                        << VL.dataColumn col1.ref (VL.nums (List.map (\i -> toFloat i) col1.vals))
--                        << VL.dataColumn col2.ref (VL.nums col2.vals)
--
--                enc =
--                    VL.encoding
--                        << VL.position VL.X [ VL.pName col1.ref, VL.pQuant ]
--                        << VL.position VL.Y [ VL.pName col2.ref, VL.pQuant ]
--            in
--            VL.toVegaLite
--                [ data []
--                , VL.line []
--                , enc []
--                , VL.height 400
--                , VL.width 600
--                ]
--    in
--    case model.duckDbForPlotResponse of
--        NotAsked ->
--            Nothing
--
--        Loading ->
--            Nothing
--
--        Failure err ->
--            Nothing
--
--        Success data ->
--            let
--                collArray =
--                    Array.fromList data.columns
--
--                col1 =
--                    case Array.get 0 collArray of
--                        Nothing ->
--                            { ref = "error"
--                            , vals = []
--                            }
--
--                        Just col ->
--                            mapColToIntegerCol col
--
--                col2 =
--                    case Array.get 1 collArray of
--                        Nothing ->
--                            { ref = "error"
--                            , vals = []
--                            }
--
--                        Just col ->
--                            mapColToFloatCol col
--            in
--            Just (spec0 col1 col2)
-- end region vega-lite
