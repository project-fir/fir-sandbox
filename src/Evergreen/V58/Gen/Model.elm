module Evergreen.V58.Gen.Model exposing (..)

import Evergreen.V58.Gen.Params.Admin
import Evergreen.V58.Gen.Params.ElmUiSvgIssue
import Evergreen.V58.Gen.Params.Home_
import Evergreen.V58.Gen.Params.IncidentReports
import Evergreen.V58.Gen.Params.Kimball
import Evergreen.V58.Gen.Params.NotFound
import Evergreen.V58.Gen.Params.Sheet
import Evergreen.V58.Gen.Params.Stories
import Evergreen.V58.Gen.Params.Stories.Basics
import Evergreen.V58.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V58.Gen.Params.Stories.FirLang
import Evergreen.V58.Gen.Params.Stories.TextEditor
import Evergreen.V58.Gen.Params.VegaLite
import Evergreen.V58.Pages.Admin
import Evergreen.V58.Pages.ElmUiSvgIssue
import Evergreen.V58.Pages.Home_
import Evergreen.V58.Pages.IncidentReports
import Evergreen.V58.Pages.Kimball
import Evergreen.V58.Pages.NotFound
import Evergreen.V58.Pages.Sheet
import Evergreen.V58.Pages.Stories.Basics
import Evergreen.V58.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V58.Pages.Stories.FirLang
import Evergreen.V58.Pages.Stories.TextEditor
import Evergreen.V58.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V58.Gen.Params.Admin.Params Evergreen.V58.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V58.Gen.Params.ElmUiSvgIssue.Params Evergreen.V58.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V58.Gen.Params.Home_.Params Evergreen.V58.Pages.Home_.Model
    | IncidentReports Evergreen.V58.Gen.Params.IncidentReports.Params Evergreen.V58.Pages.IncidentReports.Model
    | Kimball Evergreen.V58.Gen.Params.Kimball.Params Evergreen.V58.Pages.Kimball.Model
    | NotFound Evergreen.V58.Gen.Params.NotFound.Params Evergreen.V58.Pages.NotFound.Model
    | Sheet Evergreen.V58.Gen.Params.Sheet.Params Evergreen.V58.Pages.Sheet.Model
    | Stories Evergreen.V58.Gen.Params.Stories.Params
    | VegaLite Evergreen.V58.Gen.Params.VegaLite.Params Evergreen.V58.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V58.Gen.Params.Stories.Basics.Params Evergreen.V58.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V58.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V58.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V58.Gen.Params.Stories.FirLang.Params Evergreen.V58.Pages.Stories.FirLang.Model
    | Stories__TextEditor Evergreen.V58.Gen.Params.Stories.TextEditor.Params Evergreen.V58.Pages.Stories.TextEditor.Model
