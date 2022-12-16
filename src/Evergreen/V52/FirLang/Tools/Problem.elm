module Evergreen.V52.FirLang.Tools.Problem exposing (..)


type Context
    = Variable
    | Abstraction
    | SimpleExpression
    | Parenthesized
    | Application
    | Expression
    | First


type Problem
    = ExpectingPrefix
    | ExpectingBackslash
    | ExpectingLambdaCharacter
    | ExpectingPeriod
    | ExpectingSymbol String
    | EndOfInput
    | UnHandledError
    | ExpectingLParen
    | ExpectingRParen
    | ExpectingVar
