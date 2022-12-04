module Evergreen.V40.Gen.Msg exposing (..)

import Evergreen.V40.Pages.Admin
import Evergreen.V40.Pages.ElmUiSvgIssue
import Evergreen.V40.Pages.Kimball
import Evergreen.V40.Pages.Sheet
import Evergreen.V40.Pages.Stories.Basics
import Evergreen.V40.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V40.Pages.Stories.TextEditor
import Evergreen.V40.Pages.VegaLite


type Msg
    = Admin Evergreen.V40.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V40.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V40.Pages.Kimball.Msg
    | Sheet Evergreen.V40.Pages.Sheet.Msg
    | VegaLite Evergreen.V40.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V40.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V40.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__TextEditor Evergreen.V40.Pages.Stories.TextEditor.Msg
