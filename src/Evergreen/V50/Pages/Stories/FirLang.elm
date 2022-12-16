module Evergreen.V50.Pages.Stories.FirLang exposing (..)

import Evergreen.V50.Editor
import Evergreen.V50.FirLang.Lambda.Expression
import Evergreen.V50.FirLang.Tools.Problem
import Evergreen.V50.Ui
import Parser.Advanced


type alias TextEditorResult =
    Result (List (Parser.Advanced.DeadEnd Evergreen.V50.FirLang.Tools.Problem.Context Evergreen.V50.FirLang.Tools.Problem.Problem)) Evergreen.V50.FirLang.Lambda.Expression.Expr


type alias Model =
    { editor : Evergreen.V50.Editor.Editor
    , result : Maybe TextEditorResult
    , theme : Evergreen.V50.Ui.ColorTheme
    }


type Msg
    = MyEditorMsg Evergreen.V50.Editor.EditorMsg
