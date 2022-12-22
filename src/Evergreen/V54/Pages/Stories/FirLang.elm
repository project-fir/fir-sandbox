module Evergreen.V54.Pages.Stories.FirLang exposing (..)

import Evergreen.V54.Editor
import Evergreen.V54.FirLang.Lambda.Expression
import Evergreen.V54.FirLang.Tools.Problem
import Evergreen.V54.Ui
import Parser.Advanced


type alias TextEditorResult =
    Result (List (Parser.Advanced.DeadEnd Evergreen.V54.FirLang.Tools.Problem.Context Evergreen.V54.FirLang.Tools.Problem.Problem)) Evergreen.V54.FirLang.Lambda.Expression.Expr


type alias Model =
    { editor : Evergreen.V54.Editor.Editor
    , result : Maybe TextEditorResult
    , theme : Evergreen.V54.Ui.ColorTheme
    }


type Msg
    = MyEditorMsg Evergreen.V54.Editor.EditorMsg
