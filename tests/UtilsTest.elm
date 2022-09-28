module UtilsTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (Test, describe, test)
import Utils exposing (cartesian, collapseWhitespace)


suite : Test
suite =
    describe "Utils"
        [ describe "reduce whitespace - untrimmed cases"
            [ test "case 1"
                (\_ -> collapseWhitespace "\t\nsome      \t space" False |> Expect.equal " some space")
            , test "case 2"
                (\_ -> collapseWhitespace "\t\nsome      \t space\n" False |> Expect.equal " some space ")
            , test "case 3"
                (\_ -> collapseWhitespace "\t\nsome  \n    \t space" False |> Expect.equal " some space")
            ]
        , describe "reduce whitespace - trimmed cases"
            [ test "case 1"
                (\_ -> collapseWhitespace "\t\nsome      \t space" True |> Expect.equal "some space")
            , test "case 2"
                (\_ -> collapseWhitespace "\t\nsome      \t space\n" True |> Expect.equal "some space")
            , test "case 3"
                (\_ -> collapseWhitespace "\t\nsome  \n    \t space" True |> Expect.equal "some space")
            ]
        , describe "behavior of cartesian product utility function"
            [ test "case 1"
                (\_ -> cartesian [] [] |> Expect.equal [])
            , test "case 2"
                (\_ -> cartesian [ 1, 2, 3 ] [] |> Expect.equal [])
            , test "case 3"
                (\_ -> cartesian [] [ 1, 2, 3 ] |> Expect.equal [])
            , test "case 4"
                (\_ ->
                    cartesian [ 'a', 'b', 'c' ] [ 1, 2 ]
                        |> Expect.equal
                            [ ( 'a', 1 )
                            , ( 'a', 2 )
                            , ( 'b', 1 )
                            , ( 'b', 2 )
                            , ( 'c', 1 )
                            , ( 'c', 2 )
                            ]
                )
            ]
        ]
