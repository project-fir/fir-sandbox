module Evergreen.V41.Gen.Model exposing (..)

import Evergreen.V41.Gen.Params.Admin
import Evergreen.V41.Gen.Params.ElmUiSvgIssue
import Evergreen.V41.Gen.Params.Home_
import Evergreen.V41.Gen.Params.Kimball
import Evergreen.V41.Gen.Params.NotFound
import Evergreen.V41.Gen.Params.Sheet
import Evergreen.V41.Gen.Params.Stories
import Evergreen.V41.Gen.Params.Stories.Basics
import Evergreen.V41.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V41.Gen.Params.Stories.TextEditor
import Evergreen.V41.Gen.Params.VegaLite
import Evergreen.V41.Pages.Admin
import Evergreen.V41.Pages.ElmUiSvgIssue
import Evergreen.V41.Pages.Kimball
import Evergreen.V41.Pages.Sheet
import Evergreen.V41.Pages.Stories.Basics
import Evergreen.V41.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V41.Pages.Stories.TextEditor
import Evergreen.V41.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V41.Gen.Params.Admin.Params Evergreen.V41.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V41.Gen.Params.ElmUiSvgIssue.Params Evergreen.V41.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V41.Gen.Params.Home_.Params
    | Kimball Evergreen.V41.Gen.Params.Kimball.Params Evergreen.V41.Pages.Kimball.Model
    | Sheet Evergreen.V41.Gen.Params.Sheet.Params Evergreen.V41.Pages.Sheet.Model
    | Stories Evergreen.V41.Gen.Params.Stories.Params
    | VegaLite Evergreen.V41.Gen.Params.VegaLite.Params Evergreen.V41.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V41.Gen.Params.Stories.Basics.Params Evergreen.V41.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V41.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V41.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__TextEditor Evergreen.V41.Gen.Params.Stories.TextEditor.Params Evergreen.V41.Pages.Stories.TextEditor.Model
    | NotFound Evergreen.V41.Gen.Params.NotFound.Params
