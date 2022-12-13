module Evergreen.V45.Gen.Model exposing (..)

import Evergreen.V45.Gen.Params.Admin
import Evergreen.V45.Gen.Params.ElmUiSvgIssue
import Evergreen.V45.Gen.Params.Home_
import Evergreen.V45.Gen.Params.Kimball
import Evergreen.V45.Gen.Params.NotFound
import Evergreen.V45.Gen.Params.Sheet
import Evergreen.V45.Gen.Params.Stories
import Evergreen.V45.Gen.Params.Stories.Basics
import Evergreen.V45.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V45.Gen.Params.Stories.TextEditor
import Evergreen.V45.Gen.Params.VegaLite
import Evergreen.V45.Pages.Admin
import Evergreen.V45.Pages.ElmUiSvgIssue
import Evergreen.V45.Pages.Kimball
import Evergreen.V45.Pages.Sheet
import Evergreen.V45.Pages.Stories.Basics
import Evergreen.V45.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V45.Pages.Stories.TextEditor
import Evergreen.V45.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V45.Gen.Params.Admin.Params Evergreen.V45.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V45.Gen.Params.ElmUiSvgIssue.Params Evergreen.V45.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V45.Gen.Params.Home_.Params
    | Kimball Evergreen.V45.Gen.Params.Kimball.Params Evergreen.V45.Pages.Kimball.Model
    | Sheet Evergreen.V45.Gen.Params.Sheet.Params Evergreen.V45.Pages.Sheet.Model
    | Stories Evergreen.V45.Gen.Params.Stories.Params
    | VegaLite Evergreen.V45.Gen.Params.VegaLite.Params Evergreen.V45.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V45.Gen.Params.Stories.Basics.Params Evergreen.V45.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V45.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V45.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__TextEditor Evergreen.V45.Gen.Params.Stories.TextEditor.Params Evergreen.V45.Pages.Stories.TextEditor.Model
    | NotFound Evergreen.V45.Gen.Params.NotFound.Params
