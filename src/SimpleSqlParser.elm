module SimpleSqlParser exposing (parseRefsFromSql)

-- I'm not sure if this module is worthy of the word "parser", but all I need is basically functionality

import FirApi exposing (DuckDbRef)
import Parser as P exposing ((|.), (|=))


type alias SqlQuery =
    String


parseRefsFromSql : SqlQuery -> List DuckDbRef
parseRefsFromSql queryStr =
    case P.run from queryStr of
        Ok value ->
            [ value ]

        Err error ->
            []


queryParser : String -> P.Parser ()
queryParser s =
    P.succeed ()
        |. select
        |. columns
        |. from
            P.oneOf
            [ P.succeed joinOnClause
            ]


joins : P.Parser (Maybe DuckDbRef)
joins =
    P.oneOf
        [ P.succeed (Just joinOnClause)
        , P.succeed Nothing
        ]


select : P.Parser ()
select =
    P.succeed ()
        |. P.spaces
        |. P.keyword "select"
        |. P.spaces


columns : P.Parser ()
columns =
    P.succeed ()
        |. P.spaces
        |. P.symbol "*"
        |. P.spaces


from : P.Parser DuckDbRef
from =
    P.succeed DuckDbRef
        |. P.spaces
        |. P.keyword "from"
        |. P.spaces
        |= P.getChompedString (P.chompWhile Char.isAlphaNum)
        |. P.symbol "."
        |= P.getChompedString (P.chompWhile Char.isAlphaNum)
        |. P.spaces


joinUsingClause : P.Parser DuckDbRef
joinUsingClause =
    P.succeed DuckDbRef
        |. P.keyword "join"
        |. P.spaces
        |= P.getChompedString (P.chompWhile Char.isAlphaNum)
        |. P.symbol "."
        |= P.getChompedString (P.chompWhile Char.isAlphaNum)
        |. P.spaces
        |. P.keyword "using"


joinOnClause : P.Parser DuckDbRef
joinOnClause =
    P.succeed DuckDbRef
        |. P.keyword "join"
        |. P.spaces
        |= P.getChompedString (P.chompWhile Char.isAlphaNum)
        |. P.symbol "."
        |= P.getChompedString (P.chompWhile Char.isAlphaNum)
        |. P.spaces
        |. P.keyword "on"
