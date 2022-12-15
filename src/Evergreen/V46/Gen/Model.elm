module Evergreen.V46.Gen.Model exposing (..)

import Evergreen.V46.Gen.Params.Admin
import Evergreen.V46.Gen.Params.ElmUiSvgIssue
import Evergreen.V46.Gen.Params.Home_
import Evergreen.V46.Gen.Params.Kimball
import Evergreen.V46.Gen.Params.NotFound
import Evergreen.V46.Gen.Params.Sheet
import Evergreen.V46.Gen.Params.Stories
import Evergreen.V46.Gen.Params.Stories.Basics
import Evergreen.V46.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V46.Gen.Params.Stories.TextEditor
import Evergreen.V46.Gen.Params.VegaLite
import Evergreen.V46.Pages.Admin
import Evergreen.V46.Pages.ElmUiSvgIssue
import Evergreen.V46.Pages.Kimball
import Evergreen.V46.Pages.Sheet
import Evergreen.V46.Pages.Stories.Basics
import Evergreen.V46.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V46.Pages.Stories.TextEditor
import Evergreen.V46.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V46.Gen.Params.Admin.Params Evergreen.V46.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V46.Gen.Params.ElmUiSvgIssue.Params Evergreen.V46.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V46.Gen.Params.Home_.Params
    | Kimball Evergreen.V46.Gen.Params.Kimball.Params Evergreen.V46.Pages.Kimball.Model
    | Sheet Evergreen.V46.Gen.Params.Sheet.Params Evergreen.V46.Pages.Sheet.Model
    | Stories Evergreen.V46.Gen.Params.Stories.Params
    | VegaLite Evergreen.V46.Gen.Params.VegaLite.Params Evergreen.V46.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V46.Gen.Params.Stories.Basics.Params Evergreen.V46.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V46.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V46.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__TextEditor Evergreen.V46.Gen.Params.Stories.TextEditor.Params Evergreen.V46.Pages.Stories.TextEditor.Model
    | NotFound Evergreen.V46.Gen.Params.NotFound.Params
