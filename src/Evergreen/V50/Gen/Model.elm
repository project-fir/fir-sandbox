module Evergreen.V50.Gen.Model exposing (..)

import Evergreen.V50.Gen.Params.Admin
import Evergreen.V50.Gen.Params.ElmUiSvgIssue
import Evergreen.V50.Gen.Params.Home_
import Evergreen.V50.Gen.Params.Kimball
import Evergreen.V50.Gen.Params.NotFound
import Evergreen.V50.Gen.Params.Sheet
import Evergreen.V50.Gen.Params.Stories
import Evergreen.V50.Gen.Params.Stories.Basics
import Evergreen.V50.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V50.Gen.Params.Stories.FirLang
import Evergreen.V50.Gen.Params.Stories.TextEditor
import Evergreen.V50.Gen.Params.VegaLite
import Evergreen.V50.Pages.Admin
import Evergreen.V50.Pages.ElmUiSvgIssue
import Evergreen.V50.Pages.Kimball
import Evergreen.V50.Pages.Sheet
import Evergreen.V50.Pages.Stories.Basics
import Evergreen.V50.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V50.Pages.Stories.FirLang
import Evergreen.V50.Pages.Stories.TextEditor
import Evergreen.V50.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V50.Gen.Params.Admin.Params Evergreen.V50.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V50.Gen.Params.ElmUiSvgIssue.Params Evergreen.V50.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V50.Gen.Params.Home_.Params
    | Kimball Evergreen.V50.Gen.Params.Kimball.Params Evergreen.V50.Pages.Kimball.Model
    | Sheet Evergreen.V50.Gen.Params.Sheet.Params Evergreen.V50.Pages.Sheet.Model
    | Stories Evergreen.V50.Gen.Params.Stories.Params
    | VegaLite Evergreen.V50.Gen.Params.VegaLite.Params Evergreen.V50.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V50.Gen.Params.Stories.Basics.Params Evergreen.V50.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V50.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V50.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V50.Gen.Params.Stories.FirLang.Params Evergreen.V50.Pages.Stories.FirLang.Model
    | Stories__TextEditor Evergreen.V50.Gen.Params.Stories.TextEditor.Params Evergreen.V50.Pages.Stories.TextEditor.Model
    | NotFound Evergreen.V50.Gen.Params.NotFound.Params
