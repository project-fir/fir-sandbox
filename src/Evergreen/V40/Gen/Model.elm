module Evergreen.V40.Gen.Model exposing (..)

import Evergreen.V40.Gen.Params.Admin
import Evergreen.V40.Gen.Params.ElmUiSvgIssue
import Evergreen.V40.Gen.Params.Home_
import Evergreen.V40.Gen.Params.Kimball
import Evergreen.V40.Gen.Params.NotFound
import Evergreen.V40.Gen.Params.Sheet
import Evergreen.V40.Gen.Params.Stories
import Evergreen.V40.Gen.Params.Stories.Basics
import Evergreen.V40.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V40.Gen.Params.Stories.TextEditor
import Evergreen.V40.Gen.Params.VegaLite
import Evergreen.V40.Pages.Admin
import Evergreen.V40.Pages.ElmUiSvgIssue
import Evergreen.V40.Pages.Kimball
import Evergreen.V40.Pages.Sheet
import Evergreen.V40.Pages.Stories.Basics
import Evergreen.V40.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V40.Pages.Stories.TextEditor
import Evergreen.V40.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V40.Gen.Params.Admin.Params Evergreen.V40.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V40.Gen.Params.ElmUiSvgIssue.Params Evergreen.V40.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V40.Gen.Params.Home_.Params
    | Kimball Evergreen.V40.Gen.Params.Kimball.Params Evergreen.V40.Pages.Kimball.Model
    | Sheet Evergreen.V40.Gen.Params.Sheet.Params Evergreen.V40.Pages.Sheet.Model
    | Stories Evergreen.V40.Gen.Params.Stories.Params
    | VegaLite Evergreen.V40.Gen.Params.VegaLite.Params Evergreen.V40.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V40.Gen.Params.Stories.Basics.Params Evergreen.V40.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V40.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V40.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__TextEditor Evergreen.V40.Gen.Params.Stories.TextEditor.Params Evergreen.V40.Pages.Stories.TextEditor.Model
    | NotFound Evergreen.V40.Gen.Params.NotFound.Params
