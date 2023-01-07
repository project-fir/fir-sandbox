module EntityRelationDiagramStoryTest exposing (..)

import Expect exposing (Expectation)
import FirApi exposing (DuckDbColumnDescription, DuckDbRef_(..))
import Pages.Stories.EntityRelationshipDiagram as Erd
import Test exposing (Test, describe, test)



--suite : Test
--suite =
--    describe "Story - Entity Relation Diagram"
--        [ describe "`indexOf` should give the index in which the target ref is found in List DuckDbColumnsDescriptions, should it be there"
--            [ test "Nothing case"
--                (\_ -> Erd.indexOf testRef [] |> Expect.equal Nothing)
--            , test "Just case"
--                (\_ -> Erd.indexOf testRef colDescs |> Expect.equal (Just 0))
--            ]
--        ]


testRef : DuckDbRef_
testRef =
    DuckDbTable { schemaName = "test", tableName = "my_table" }


colDescs : List DuckDbColumnDescription
colDescs =
    [ { name = "my_column"
      , parentRef = testRef
      , dataType = "STRING"
      }
    ]
