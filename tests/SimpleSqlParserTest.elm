module SimpleSqlParserTest exposing (..)

import Expect exposing (Expectation)
import Set
import SimpleSqlParser exposing (parseRefsFromSql)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "SimpleSqlParser"
        [ describe "pluck out duckdb refs from query"
            [ test "trivial case"
                (\_ ->
                    parseRefsFromSql ""
                        |> Expect.equal []
                )
            , test "case 1"
                (\_ ->
                    parseRefsFromSql "select from foo.bar "
                        |> Expect.equal [ { schemaName = "foo", tableName = "bar" } ]
                )
            , test "case 2"
                (\_ ->
                    parseRefsFromSql "select * from foo.bar b"
                        |> Expect.equal [ { schemaName = "foo", tableName = "bar" } ]
                )
            , test "case 3"
                (\_ ->
                    parseRefsFromSql "select * from foo.bar join foo.bar2 using bar_id"
                        |> Expect.equal
                            [ { schemaName = "foo", tableName = "bar" }
                            , { schemaName = "foo", tableName = "bar2" }
                            ]
                )
            , test "case 4"
                (\_ ->
                    parseRefsFromSql "select * from foo.bar b1 join foo.bar2 using bar_id"
                        |> Expect.equal
                            [ { schemaName = "foo", tableName = "bar" }
                            , { schemaName = "foo", tableName = "bar2" }
                            ]
                )
            , test "case 5"
                (\_ ->
                    parseRefsFromSql "select * from foo.bar b1 join foo.bar2 b2 using bar_id"
                        |> Expect.equal
                            [ { schemaName = "foo", tableName = "bar" }
                            , { schemaName = "foo", tableName = "bar2" }
                            ]
                )
            , test "case 6"
                (\_ ->
                    parseRefsFromSql "select * from foo.bar b1 join foo.bar2 b2 on b1.bar_id = b2.bar_id"
                        |> Expect.equal
                            [ { schemaName = "foo", tableName = "bar" }
                            , { schemaName = "foo", tableName = "bar2" }
                            ]
                )
            ]
        ]
