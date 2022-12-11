module Evergreen.V43.Gen.Msg exposing (..)

import Evergreen.V43.Pages.Admin
import Evergreen.V43.Pages.ElmUiSvgIssue
import Evergreen.V43.Pages.Kimball
import Evergreen.V43.Pages.Sheet
import Evergreen.V43.Pages.Stories.Basics
import Evergreen.V43.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V43.Pages.Stories.TextEditor
import Evergreen.V43.Pages.VegaLite


type Msg
    = Admin Evergreen.V43.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V43.Pages.ElmUiSvgIssue.Msg
    | Kimball Evergreen.V43.Pages.Kimball.Msg
    | Sheet Evergreen.V43.Pages.Sheet.Msg
    | VegaLite Evergreen.V43.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V43.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V43.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__TextEditor Evergreen.V43.Pages.Stories.TextEditor.Msg
