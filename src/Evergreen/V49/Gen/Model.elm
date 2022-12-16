module Evergreen.V49.Gen.Model exposing (..)

import Evergreen.V49.Gen.Params.Admin
import Evergreen.V49.Gen.Params.ElmUiSvgIssue
import Evergreen.V49.Gen.Params.Home_
import Evergreen.V49.Gen.Params.Kimball
import Evergreen.V49.Gen.Params.NotFound
import Evergreen.V49.Gen.Params.Sheet
import Evergreen.V49.Gen.Params.Stories
import Evergreen.V49.Gen.Params.Stories.Basics
import Evergreen.V49.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V49.Gen.Params.Stories.FirLang
import Evergreen.V49.Gen.Params.Stories.TextEditor
import Evergreen.V49.Gen.Params.VegaLite
import Evergreen.V49.Pages.Admin
import Evergreen.V49.Pages.ElmUiSvgIssue
import Evergreen.V49.Pages.Kimball
import Evergreen.V49.Pages.Sheet
import Evergreen.V49.Pages.Stories.Basics
import Evergreen.V49.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V49.Pages.Stories.FirLang
import Evergreen.V49.Pages.Stories.TextEditor
import Evergreen.V49.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V49.Gen.Params.Admin.Params Evergreen.V49.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V49.Gen.Params.ElmUiSvgIssue.Params Evergreen.V49.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V49.Gen.Params.Home_.Params
    | Kimball Evergreen.V49.Gen.Params.Kimball.Params Evergreen.V49.Pages.Kimball.Model
    | Sheet Evergreen.V49.Gen.Params.Sheet.Params Evergreen.V49.Pages.Sheet.Model
    | Stories Evergreen.V49.Gen.Params.Stories.Params
    | VegaLite Evergreen.V49.Gen.Params.VegaLite.Params Evergreen.V49.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V49.Gen.Params.Stories.Basics.Params Evergreen.V49.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V49.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V49.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V49.Gen.Params.Stories.FirLang.Params Evergreen.V49.Pages.Stories.FirLang.Model
    | Stories__TextEditor Evergreen.V49.Gen.Params.Stories.TextEditor.Params Evergreen.V49.Pages.Stories.TextEditor.Model
    | NotFound Evergreen.V49.Gen.Params.NotFound.Params
