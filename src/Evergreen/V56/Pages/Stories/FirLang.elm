module Evergreen.V56.Pages.Stories.FirLang exposing (..)

import Evergreen.V56.Editor
import Evergreen.V56.FirLang.Lambda.Expression
import Evergreen.V56.FirLang.Tools.Problem
import Evergreen.V56.Ui
import Parser.Advanced


type alias TextEditorResult =
    Result (List (Parser.Advanced.DeadEnd Evergreen.V56.FirLang.Tools.Problem.Context Evergreen.V56.FirLang.Tools.Problem.Problem)) Evergreen.V56.FirLang.Lambda.Expression.Expr


type alias Model =
    { editor : Evergreen.V56.Editor.Editor
    , result : Maybe TextEditorResult
    , theme : Evergreen.V56.Ui.ColorTheme
    }


type Msg
    = MyEditorMsg Evergreen.V56.Editor.EditorMsg
