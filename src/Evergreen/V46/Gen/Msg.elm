module Evergreen.V46.Gen.Msg exposing (..)

import Evergreen.V46.Pages.Admin
import Evergreen.V46.Pages.ElmUiSvgIssue
import Evergreen.V46.Pages.Kimball
import Evergreen.V46.Pages.Sheet
import Evergreen.V46.Pages.Stories.Basics
import Evergreen.V46.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V46.Pages.Stories.TextEditor
import Evergreen.V46.Pages.VegaLite


type Msg
    = Admin Evergreen.V46.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V46.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V46.Pages.Kimball.Msg
    | Sheet Evergreen.V46.Pages.Sheet.Msg
    | VegaLite Evergreen.V46.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V46.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V46.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__TextEditor Evergreen.V46.Pages.Stories.TextEditor.Msg
