module DuckDb exposing (ColumnName, ComputedDuckDbColumn, ComputedDuckDbColumnDescription, DuckDbColumn(..), DuckDbColumnDescription(..), DuckDbMetaResponse, DuckDbQueryResponse, DuckDbRef, DuckDbRefString, DuckDbRef_(..), DuckDbRefsResponse, PersistedDuckDbColumn, PersistedDuckDbColumnDescription, PingResponse, Ref, SchemaName, TableName, Val(..), fetchDuckDbTableRefs, pingServer, queryDuckDb, queryDuckDbMeta, refEquals, refToString, taskBuildDateDimTable, uploadFile)

import Config exposing (apiHost)
import File exposing (File)
import Http exposing (Error(..))
import ISO8601 as Iso
import Json.Decode as JD
import Json.Encode as JE


type
    Ref
    -- Top-level database reference, should this app support BigQuery in the future
    -- for example, introduce a BigQuery variant of this type (and maybe pull this data type into
    -- a non-db specific module)
    = DuckDb DuckDbRef_



-- begin region: DuckDb-specific types
--
-- A DuckDbRef points to a SQL-queryable source, the current fir-api only exposes DuckDB tables and views, but a URI to a
-- .parquet file could be supported, with backend changes (and likely some import conventions I've yet to think through)


type alias DuckDbRef =
    { schemaName : SchemaName, tableName : TableName }


refEquals : DuckDbRef -> DuckDbRef -> Bool
refEquals lhs rhs =
    (lhs.schemaName == rhs.schemaName) && (lhs.tableName == rhs.tableName)


refToString : DuckDbRef -> DuckDbRefString
refToString ref =
    ref.schemaName ++ "." ++ ref.tableName


type
    DuckDbRef_
    -- While DuckDB supports schema-less tables, I don't =)
    = DuckDbView DuckDbRef
    | DuckDbTable DuckDbRef


type alias DuckDbRefString =
    String


type alias SchemaName =
    -- The 'bi' in `select * from bi.foo`
    String


type alias TableName =
    -- The 'foo' in `select * from bi.foo`
    String


type alias ColumnName =
    -- The 'col_a' in `select f.col_a from bi.foo f`
    String


type DuckDbColumn
    = Persisted PersistedDuckDbColumn
    | Computed ComputedDuckDbColumn


type alias PersistedDuckDbColumn =
    { name : ColumnName
    , parentRef : DuckDbRef_
    , dataType : String
    , vals : List (Maybe Val)
    }


type alias ComputedDuckDbColumn =
    -- TODO: Is it possible to generalize the notion of ownerRef to apply to computed columns?
    --       I believe this would involve a SQL parser =/
    { name : ColumnName
    , dataType : String
    , vals : List (Maybe Val)
    }


type DuckDbColumnDescription
    = Persisted_ PersistedDuckDbColumnDescription
    | Computed_ ComputedDuckDbColumnDescription


type alias PersistedDuckDbColumnDescription =
    -- Just the metadata for a DuckDbColumn
    { name : ColumnName
    , parentRef : DuckDbRef_
    , dataType : String
    }


type alias ComputedDuckDbColumnDescription =
    -- TODO: Is it possible to generalize the notion of ownerRef to apply to computed columns?
    --       I believe this would involve a SQL parser =/
    { name : ColumnName
    , dataType : String
    }


type
    Val
    -- Maps Elm tag to DuckDB val type
    = Varchar_ String
    | Time_ Iso.Time
    | Bool_ Bool
    | Float_ Float
    | Int_ Int
    | Unknown



-- end region: DuckDb-specific types
-- begin region: fir-api DuckDb response types


type alias PingResponse =
    { message : String
    }


type alias TaskResponse =
    { message : String
    }


type alias DuckDbQueryResponse =
    { columns : List DuckDbColumn
    }


type alias DuckDbMetaResponse =
    { columnDescriptions : List DuckDbColumnDescription
    , refs : List DuckDbRef
    }


type alias DuckDbRefsResponse =
    { refs : List DuckDbRef
    }



-- end region: fir-api DuckDb response types
-- begin region: fir-api HTTP utility functions
--
-- TODO: The two DuckDB query decoders needs to support the variants of DuckDbRef, like View
--       currently I've hardcoded Table


pingServer : (Result Error PingResponse -> msg) -> Cmd msg
pingServer onResponse =
    let
        pingResponseDecoder : JD.Decoder PingResponse
        pingResponseDecoder =
            JD.map PingResponse
                (JD.field "message" JD.string)
    in
    Http.get
        { url = apiHost ++ "/ping"
        , expect = Http.expectJson onResponse pingResponseDecoder
        }


taskBuildDateDimTable : String -> String -> DuckDbRef -> (Result Error TaskResponse -> msg) -> Cmd msg
taskBuildDateDimTable startDate endDate ref onResponse =
    let
        duckDbQueryEncoder : JE.Value
        duckDbQueryEncoder =
            JE.object
                [ ( "start_date", JE.string startDate )
                , ( "end_date", JE.string endDate )
                , ( "ref", refEncoder ref )
                ]

        taskResponseDecoder : JD.Decoder TaskResponse
        taskResponseDecoder =
            JD.map TaskResponse
                (JD.field "message" JD.string)
    in
    Http.post
        { url = apiHost ++ "/tasks/generate_date_dim"
        , expect = Http.expectJson onResponse taskResponseDecoder
        , body = Http.jsonBody duckDbQueryEncoder
        }


queryDuckDb : String -> Bool -> List DuckDbRef -> (Result Error DuckDbQueryResponse -> msg) -> Cmd msg
queryDuckDb query allowFallback refs onResponse =
    let
        duckDbQueryEncoder : JE.Value
        duckDbQueryEncoder =
            JE.object
                [ ( "query_str", JE.string query )
                , ( "allow_blob_fallback", JE.bool allowFallback )
                , ( "fallback_table_refs", JE.list refEncoder refs )
                ]

        duckDbQueryResponseDecoder : JD.Decoder DuckDbQueryResponse
        duckDbQueryResponseDecoder =
            let
                columnDecoderHelper : JD.Decoder PersistedDuckDbColumn
                columnDecoderHelper =
                    JD.field "type" JD.string |> JD.andThen decoderByType

                timeDecoder : JD.Decoder Iso.Time
                timeDecoder =
                    JD.string
                        |> JD.andThen
                            (\val ->
                                case Iso.fromString val of
                                    Err err ->
                                        JD.fail err

                                    Ok time ->
                                        JD.succeed <| time
                            )

                decoderByType : String -> JD.Decoder PersistedDuckDbColumn
                decoderByType type_ =
                    case type_ of
                        "VARCHAR" ->
                            JD.map4 PersistedDuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Varchar_ JD.string))))

                        "INTEGER" ->
                            JD.map4 PersistedDuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Int_ JD.int))))

                        "BIGINT" ->
                            JD.map4 PersistedDuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Int_ JD.int))))

                        "HUGEINT" ->
                            JD.map4 PersistedDuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Int_ JD.int))))

                        "BOOLEAN" ->
                            JD.map4 PersistedDuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Bool_ JD.bool))))

                        "DOUBLE" ->
                            JD.map4 PersistedDuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Float_ JD.float))))

                        "DATE" ->
                            JD.map4 PersistedDuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Varchar_ JD.string))))

                        "TIMESTAMP" ->
                            JD.map4 PersistedDuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Time_ timeDecoder))))

                        _ ->
                            -- This feels wrong to me, but unsure how else to workaround the string pattern matching
                            -- Should this fail loudly?
                            JD.map4 PersistedDuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                                (JD.field "type" JD.string)
                                (JD.list (JD.maybe (JD.succeed Unknown)))
            in
            JD.map DuckDbQueryResponse
                (JD.field "columns" (JD.list (JD.map Persisted columnDecoderHelper)))
    in
    Http.post
        { url = apiHost ++ "/duckdb"
        , body = Http.jsonBody duckDbQueryEncoder
        , expect = Http.expectJson onResponse duckDbQueryResponseDecoder
        }


queryDuckDbMeta : String -> Bool -> List DuckDbRef -> (Result Error DuckDbMetaResponse -> msg) -> Cmd msg
queryDuckDbMeta query allowFallback refs onResponse =
    let
        duckDbQueryEncoder : JE.Value
        duckDbQueryEncoder =
            JE.object
                [ ( "query_str", JE.string query )
                , ( "allow_blob_fallback", JE.bool allowFallback )
                , ( "fallback_table_refs", JE.list refEncoder refs )
                ]

        duckDbMetaResponseDecoder : JD.Decoder DuckDbMetaResponse
        duckDbMetaResponseDecoder =
            let
                columnDescriptionDecoder : JD.Decoder PersistedDuckDbColumnDescription
                columnDescriptionDecoder =
                    JD.map3 PersistedDuckDbColumnDescription
                        (JD.field "name" JD.string)
                        (JD.field "owning_ref" (JD.map DuckDbTable refDecoder))
                        (JD.field "type" JD.string)
            in
            JD.map2 DuckDbMetaResponse
                (JD.field "columns" (JD.list (JD.map Persisted_ columnDescriptionDecoder)))
                (JD.field "refs" (JD.list refDecoder))
    in
    Http.post
        { url = apiHost ++ "/duckdb"
        , body = Http.jsonBody duckDbQueryEncoder
        , expect = Http.expectJson onResponse duckDbMetaResponseDecoder
        }


fetchDuckDbTableRefs : (Result Error DuckDbRefsResponse -> msg) -> Cmd msg
fetchDuckDbTableRefs onResponse =
    let
        duckDbTableRefsResponseDecoder : JD.Decoder DuckDbRefsResponse
        duckDbTableRefsResponseDecoder =
            JD.map DuckDbRefsResponse
                (JD.field "refs" (JD.list refDecoder))
    in
    Http.get
        { url = apiHost ++ "/duckdb/refs"
        , expect = Http.expectJson onResponse duckDbTableRefsResponseDecoder
        }


refDecoder : JD.Decoder DuckDbRef
refDecoder =
    JD.map2 DuckDbRef
        (JD.field "schema_name" JD.string)
        (JD.field "table_name" JD.string)


refEncoder : DuckDbRef -> JE.Value
refEncoder ref =
    JE.object
        [ ( "schema_name", JE.string ref.schemaName )
        , ( "table_name", JE.string ref.tableName )
        ]


uploadFile : File -> String -> String -> (Result Http.Error () -> msg) -> Cmd msg
uploadFile file schemaName tableName onResponse =
    Http.request
        { method = "POST"
        , url = apiHost ++ "/duckdb/files"
        , headers = []
        , body =
            Http.multipartBody
                [ Http.filePart "file" file
                , Http.stringPart "schema_name" schemaName
                , Http.stringPart "table_name" tableName
                ]
        , expect = Http.expectWhatever onResponse
        , timeout = Nothing
        , tracker = Just "upload"
        }



-- end region: fir-api HTTP utility functions
