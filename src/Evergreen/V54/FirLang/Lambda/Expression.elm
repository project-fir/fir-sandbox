module Evergreen.V54.FirLang.Lambda.Expression exposing (..)


type Expr
    = Var String
    | Lambda String Expr
    | Apply Expr Expr
