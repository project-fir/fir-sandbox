module Evergreen.V43.Gen.Model exposing (..)

import Evergreen.V43.Gen.Params.Admin
import Evergreen.V43.Gen.Params.ElmUiSvgIssue
import Evergreen.V43.Gen.Params.Home_
import Evergreen.V43.Gen.Params.Kimball
import Evergreen.V43.Gen.Params.NotFound
import Evergreen.V43.Gen.Params.Sheet
import Evergreen.V43.Gen.Params.Stories
import Evergreen.V43.Gen.Params.Stories.Basics
import Evergreen.V43.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V43.Gen.Params.Stories.TextEditor
import Evergreen.V43.Gen.Params.VegaLite
import Evergreen.V43.Pages.Admin
import Evergreen.V43.Pages.ElmUiSvgIssue
import Evergreen.V43.Pages.Kimball
import Evergreen.V43.Pages.Sheet
import Evergreen.V43.Pages.Stories.Basics
import Evergreen.V43.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V43.Pages.Stories.TextEditor
import Evergreen.V43.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V43.Gen.Params.Admin.Params Evergreen.V43.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V43.Gen.Params.ElmUiSvgIssue.Params Evergreen.V43.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V43.Gen.Params.Home_.Params
    | Kimball Evergreen.V43.Gen.Params.Kimball.Params Evergreen.V43.Pages.Kimball.Model
    | Sheet Evergreen.V43.Gen.Params.Sheet.Params Evergreen.V43.Pages.Sheet.Model
    | Stories Evergreen.V43.Gen.Params.Stories.Params
    | VegaLite Evergreen.V43.Gen.Params.VegaLite.Params Evergreen.V43.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V43.Gen.Params.Stories.Basics.Params Evergreen.V43.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V43.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V43.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__TextEditor Evergreen.V43.Gen.Params.Stories.TextEditor.Params Evergreen.V43.Pages.Stories.TextEditor.Model
    | NotFound Evergreen.V43.Gen.Params.NotFound.Params
