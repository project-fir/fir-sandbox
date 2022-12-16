module Evergreen.V48.Gen.Model exposing (..)

import Evergreen.V48.Gen.Params.Admin
import Evergreen.V48.Gen.Params.ElmUiSvgIssue
import Evergreen.V48.Gen.Params.Home_
import Evergreen.V48.Gen.Params.Kimball
import Evergreen.V48.Gen.Params.NotFound
import Evergreen.V48.Gen.Params.Sheet
import Evergreen.V48.Gen.Params.Stories
import Evergreen.V48.Gen.Params.Stories.Basics
import Evergreen.V48.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V48.Gen.Params.Stories.FirLang
import Evergreen.V48.Gen.Params.Stories.TextEditor
import Evergreen.V48.Gen.Params.VegaLite
import Evergreen.V48.Pages.Admin
import Evergreen.V48.Pages.ElmUiSvgIssue
import Evergreen.V48.Pages.Kimball
import Evergreen.V48.Pages.Sheet
import Evergreen.V48.Pages.Stories.Basics
import Evergreen.V48.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V48.Pages.Stories.FirLang
import Evergreen.V48.Pages.Stories.TextEditor
import Evergreen.V48.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V48.Gen.Params.Admin.Params Evergreen.V48.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V48.Gen.Params.ElmUiSvgIssue.Params Evergreen.V48.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V48.Gen.Params.Home_.Params
    | Kimball Evergreen.V48.Gen.Params.Kimball.Params Evergreen.V48.Pages.Kimball.Model
    | Sheet Evergreen.V48.Gen.Params.Sheet.Params Evergreen.V48.Pages.Sheet.Model
    | Stories Evergreen.V48.Gen.Params.Stories.Params
    | VegaLite Evergreen.V48.Gen.Params.VegaLite.Params Evergreen.V48.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V48.Gen.Params.Stories.Basics.Params Evergreen.V48.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V48.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V48.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V48.Gen.Params.Stories.FirLang.Params Evergreen.V48.Pages.Stories.FirLang.Model
    | Stories__TextEditor Evergreen.V48.Gen.Params.Stories.TextEditor.Params Evergreen.V48.Pages.Stories.TextEditor.Model
    | NotFound Evergreen.V48.Gen.Params.NotFound.Params
