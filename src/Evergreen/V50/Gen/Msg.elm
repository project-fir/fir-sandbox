module Evergreen.V50.Gen.Msg exposing (..)

import Evergreen.V50.Pages.Admin
import Evergreen.V50.Pages.ElmUiSvgIssue
import Evergreen.V50.Pages.Kimball
import Evergreen.V50.Pages.Sheet
import Evergreen.V50.Pages.Stories.Basics
import Evergreen.V50.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V50.Pages.Stories.FirLang
import Evergreen.V50.Pages.Stories.TextEditor
import Evergreen.V50.Pages.VegaLite


type Msg
    = Admin Evergreen.V50.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V50.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V50.Pages.Kimball.Msg
    | Sheet Evergreen.V50.Pages.Sheet.Msg
    | VegaLite Evergreen.V50.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V50.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V50.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V50.Pages.Stories.FirLang.Msg
    | Stories__TextEditor Evergreen.V50.Pages.Stories.TextEditor.Msg
