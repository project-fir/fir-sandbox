module Evergreen.V48.Gen.Msg exposing (..)

import Evergreen.V48.Pages.Admin
import Evergreen.V48.Pages.ElmUiSvgIssue
import Evergreen.V48.Pages.Kimball
import Evergreen.V48.Pages.Sheet
import Evergreen.V48.Pages.Stories.Basics
import Evergreen.V48.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V48.Pages.Stories.FirLang
import Evergreen.V48.Pages.Stories.TextEditor
import Evergreen.V48.Pages.VegaLite


type Msg
    = Admin Evergreen.V48.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V48.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V48.Pages.Kimball.Msg
    | Sheet Evergreen.V48.Pages.Sheet.Msg
    | VegaLite Evergreen.V48.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V48.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V48.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V48.Pages.Stories.FirLang.Msg
    | Stories__TextEditor Evergreen.V48.Pages.Stories.TextEditor.Msg
