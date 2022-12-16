module Evergreen.V49.Gen.Msg exposing (..)

import Evergreen.V49.Pages.Admin
import Evergreen.V49.Pages.ElmUiSvgIssue
import Evergreen.V49.Pages.Kimball
import Evergreen.V49.Pages.Sheet
import Evergreen.V49.Pages.Stories.Basics
import Evergreen.V49.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V49.Pages.Stories.FirLang
import Evergreen.V49.Pages.Stories.TextEditor
import Evergreen.V49.Pages.VegaLite


type Msg
    = Admin Evergreen.V49.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V49.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V49.Pages.Kimball.Msg
    | Sheet Evergreen.V49.Pages.Sheet.Msg
    | VegaLite Evergreen.V49.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V49.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V49.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V49.Pages.Stories.FirLang.Msg
    | Stories__TextEditor Evergreen.V49.Pages.Stories.TextEditor.Msg
