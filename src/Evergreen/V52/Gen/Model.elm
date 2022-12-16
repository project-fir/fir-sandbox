module Evergreen.V52.Gen.Model exposing (..)

import Evergreen.V52.Gen.Params.Admin
import Evergreen.V52.Gen.Params.ElmUiSvgIssue
import Evergreen.V52.Gen.Params.Home_
import Evergreen.V52.Gen.Params.Kimball
import Evergreen.V52.Gen.Params.NotFound
import Evergreen.V52.Gen.Params.Sheet
import Evergreen.V52.Gen.Params.Stories
import Evergreen.V52.Gen.Params.Stories.Basics
import Evergreen.V52.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V52.Gen.Params.Stories.FirLang
import Evergreen.V52.Gen.Params.Stories.TextEditor
import Evergreen.V52.Gen.Params.VegaLite
import Evergreen.V52.Pages.Admin
import Evergreen.V52.Pages.ElmUiSvgIssue
import Evergreen.V52.Pages.Home_
import Evergreen.V52.Pages.Kimball
import Evergreen.V52.Pages.NotFound
import Evergreen.V52.Pages.Sheet
import Evergreen.V52.Pages.Stories.Basics
import Evergreen.V52.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V52.Pages.Stories.FirLang
import Evergreen.V52.Pages.Stories.TextEditor
import Evergreen.V52.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V52.Gen.Params.Admin.Params Evergreen.V52.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V52.Gen.Params.ElmUiSvgIssue.Params Evergreen.V52.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V52.Gen.Params.Home_.Params Evergreen.V52.Pages.Home_.Model
    | Kimball Evergreen.V52.Gen.Params.Kimball.Params Evergreen.V52.Pages.Kimball.Model
    | NotFound Evergreen.V52.Gen.Params.NotFound.Params Evergreen.V52.Pages.NotFound.Model
    | Sheet Evergreen.V52.Gen.Params.Sheet.Params Evergreen.V52.Pages.Sheet.Model
    | Stories Evergreen.V52.Gen.Params.Stories.Params
    | VegaLite Evergreen.V52.Gen.Params.VegaLite.Params Evergreen.V52.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V52.Gen.Params.Stories.Basics.Params Evergreen.V52.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V52.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V52.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V52.Gen.Params.Stories.FirLang.Params Evergreen.V52.Pages.Stories.FirLang.Model
    | Stories__TextEditor Evergreen.V52.Gen.Params.Stories.TextEditor.Params Evergreen.V52.Pages.Stories.TextEditor.Model
