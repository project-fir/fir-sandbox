module SimpleSqlParser exposing (parseRefsFromSql)

-- I'm not sure if this module is worthy of the word "parser", but all I need is basically functionality

import FirApi exposing (DuckDbRef)


type alias SqlQuery =
    String


parseRefsFromSql : SqlQuery -> List DuckDbRef
parseRefsFromSql queryStr =
    []
