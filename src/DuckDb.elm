module DuckDb exposing (ColumnName, DuckDbColumnDescription, DuckDbRef, Ref, SchemaName, TableName, Val, queryDuckDb)

import Config exposing (apiHost)
import Http exposing (Error(..))
import ISO8601 as Iso
import Json.Decode as JD
import Json.Encode as JE
import QueryBuilder exposing (ColumnRef)
import RemoteData exposing (RemoteData, asCmd)
import Url exposing (fromString)


type
    Ref
    -- Top-level database reference, should this app support BigQuery in the future
    -- for example, introduce a BigQuery variant of this type (and maybe pull this data type into
    -- a non-db specific module)
    = DuckDb DuckDbRef



-- begin region: DuckDb-specific types
--
-- A DuckDbRef points to a SQL-queryable source, the current fir-api only exposes DuckDB tables and views, but a URI to a
-- .parquet file could be supported, with backend changes (and likely some import conventions I've yet to think through)


type
    DuckDbRef
    -- While DuckDB supports schema-less tables, I don't =)
    = View { schemaName : SchemaName, tableName : TableName }
    | Table { schemaRef : SchemaName, tableRef : TableName }


type alias SchemaName =
    -- The 'bi' in `select * from bi.foo`
    String


type alias TableName =
    -- The 'foo' in `select * from bi.foo`
    String


type alias ColumnName =
    -- The 'col_a' in `select f.col_a from bi.foo f`
    String


type alias DuckDbColumn =
    -- A DuckDbColumn is owned by a DuckDbRef
    -- The plain-text field `type_` is used by JSON decoding, and delegates the decoder
    -- to its proper `Val` variant
    -- TODO: Need to put thought into nullability, there may be performance implications with the
    --       current superfluous use of `Maybe`, but for the moment it's a bit simpler
    --
    { name : ColumnName
    , owningRef : DuckDbRef
    , type_ : String
    , vals : List (Maybe Val)
    }


type alias DuckDbColumnDescription =
    -- Just the metadata for a DuckDbColumn
    { ref : ColumnName
    , owningRef : DuckDbRef
    , type_ : String
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


type alias DuckDbQueryResponse =
    { columns : List DuckDbColumn
    }


type alias DuckDbMetaResponse =
    { colDescs : List DuckDbColumnDescription
    }


type alias DuckDbTableRefsResponse =
    { refs : List TableName
    }



-- end region: fir-api DuckDb response types
-- begin region: fir-api HTTP utility functions


queryDuckDb : String -> Bool -> List TableName -> (Result Error DuckDbQueryResponse -> msg) -> Cmd msg
queryDuckDb query allowFallback refs onResponse =
    let
        duckDbQueryEncoder : JE.Value
        duckDbQueryEncoder =
            JE.object
                [ ( "query_str", JE.string query )
                , ( "allow_blob_fallback", JE.bool allowFallback )
                , ( "fallback_table_refs", JE.list JE.string refs )
                ]

        duckDbQueryResponseDecoder : JD.Decoder DuckDbQueryResponse
        duckDbQueryResponseDecoder =
            let
                columnDecoderHelper : JD.Decoder DuckDbColumn
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

                decoderByType : String -> JD.Decoder DuckDbColumn
                decoderByType type_ =
                    case type_ of
                        "VARCHAR" ->
                            JD.map3 DuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Varchar_ JD.string))))

                        "INTEGER" ->
                            JD.map3 DuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Int_ JD.int))))

                        "BIGINT" ->
                            JD.map3 DuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Int_ JD.int))))

                        "HUGEINT" ->
                            JD.map3 DuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Int_ JD.int))))

                        "BOOLEAN" ->
                            JD.map3 DuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Bool_ JD.bool))))

                        "DOUBLE" ->
                            JD.map3 DuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Float_ JD.float))))

                        "DATE" ->
                            JD.map3 DuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Varchar_ JD.string))))

                        "TIMESTAMP" ->
                            JD.map3 DuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "type" JD.string)
                                (JD.field "values" (JD.list (JD.maybe (JD.map Time_ timeDecoder))))

                        _ ->
                            -- This feels wrong to me, but unsure how else to workaround the string pattern matching
                            -- Should this fail loudly?
                            JD.map3 DuckDbColumn
                                (JD.field "name" JD.string)
                                (JD.field "type" JD.string)
                                (JD.list (JD.maybe (JD.succeed Unknown)))
            in
            JD.map DuckDbQueryResponse
                (JD.field "columns" (JD.list columnDecoderHelper))
    in
    Http.post
        { url = apiHost ++ "/duckdb"
        , body = Http.jsonBody duckDbQueryEncoder
        , expect = Http.expectJson onResponse duckDbQueryResponseDecoder
        }



-- begin region: fir-api HTTP utility functions
