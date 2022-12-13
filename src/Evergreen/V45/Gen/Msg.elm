module Evergreen.V45.Gen.Msg exposing (..)

import Evergreen.V45.Pages.Admin
import Evergreen.V45.Pages.ElmUiSvgIssue
import Evergreen.V45.Pages.Kimball
import Evergreen.V45.Pages.Sheet
import Evergreen.V45.Pages.Stories.Basics
import Evergreen.V45.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V45.Pages.Stories.TextEditor
import Evergreen.V45.Pages.VegaLite


type Msg
    = Admin Evergreen.V45.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V45.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V45.Pages.Kimball.Msg
    | Sheet Evergreen.V45.Pages.Sheet.Msg
    | VegaLite Evergreen.V45.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V45.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V45.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__TextEditor Evergreen.V45.Pages.Stories.TextEditor.Msg
