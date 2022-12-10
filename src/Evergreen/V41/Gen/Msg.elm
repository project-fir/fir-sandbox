module Evergreen.V41.Gen.Msg exposing (..)

import Evergreen.V41.Pages.Admin
import Evergreen.V41.Pages.ElmUiSvgIssue
import Evergreen.V41.Pages.Kimball
import Evergreen.V41.Pages.Sheet
import Evergreen.V41.Pages.Stories.Basics
import Evergreen.V41.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V41.Pages.Stories.TextEditor
import Evergreen.V41.Pages.VegaLite


type Msg
    = Admin Evergreen.V41.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V41.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V41.Pages.Kimball.Msg
    | Sheet Evergreen.V41.Pages.Sheet.Msg
    | VegaLite Evergreen.V41.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V41.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V41.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__TextEditor Evergreen.V41.Pages.Stories.TextEditor.Msg
