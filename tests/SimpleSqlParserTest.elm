module SimpleSqlParserTest exposing (..)

import Expect exposing (Expectation)
import Set
import SimpleSqlParser exposing (parseRefsFromSql)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "SimpleSqlParser"
        [ describe "pluck out duckdb refs from query"
            [ test "case 1"
                (\_ ->
                    parseRefsFromSql "select * from foo.bar"
                        -- TODO: Implement things!
                        --|> Expect.equal [ { schemaName = "foo", tableName = "bar" } ]
                        |> Expect.equal []
                )
            ]
        ]
