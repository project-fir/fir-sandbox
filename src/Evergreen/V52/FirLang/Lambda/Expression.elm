module Evergreen.V52.FirLang.Lambda.Expression exposing (..)


type Expr
    = Var String
    | Lambda String Expr
    | Apply Expr Expr
