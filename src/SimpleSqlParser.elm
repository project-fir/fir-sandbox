module SimpleSqlParser exposing (parseRefsFromSql)

-- I'm not sure if this module is worthy of the word "parser", but all I need is basically functionality

import FirApi exposing (DuckDbRef)
import Parser as P exposing ((|.), (|=))


type alias SqlQuery =
    String


parseRefsFromSql : SqlQuery -> List DuckDbRef
parseRefsFromSql queryStr =
    case P.run fromClause queryStr of
        Ok value ->
            [ value ]

        Err error ->
            []


fromClause : P.Parser DuckDbRef
fromClause =
    P.succeed DuckDbRef
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
