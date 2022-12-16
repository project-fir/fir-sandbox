module Evergreen.V52.Pages.Stories.FirLang exposing (..)

import Evergreen.V52.Editor
import Evergreen.V52.FirLang.Lambda.Expression
import Evergreen.V52.FirLang.Tools.Problem
import Evergreen.V52.Ui
import Parser.Advanced


type alias TextEditorResult =
    Result (List (Parser.Advanced.DeadEnd Evergreen.V52.FirLang.Tools.Problem.Context Evergreen.V52.FirLang.Tools.Problem.Problem)) Evergreen.V52.FirLang.Lambda.Expression.Expr


type alias Model =
    { editor : Evergreen.V52.Editor.Editor
    , result : Maybe TextEditorResult
    , theme : Evergreen.V52.Ui.ColorTheme
    }


type Msg
    = MyEditorMsg Evergreen.V52.Editor.EditorMsg
