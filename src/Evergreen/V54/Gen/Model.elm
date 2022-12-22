module Evergreen.V54.Gen.Model exposing (..)

import Evergreen.V54.Gen.Params.Admin
import Evergreen.V54.Gen.Params.ElmUiSvgIssue
import Evergreen.V54.Gen.Params.Home_
import Evergreen.V54.Gen.Params.IncidentReports
import Evergreen.V54.Gen.Params.Kimball
import Evergreen.V54.Gen.Params.NotFound
import Evergreen.V54.Gen.Params.Sheet
import Evergreen.V54.Gen.Params.Stories
import Evergreen.V54.Gen.Params.Stories.Basics
import Evergreen.V54.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V54.Gen.Params.Stories.FirLang
import Evergreen.V54.Gen.Params.Stories.TextEditor
import Evergreen.V54.Gen.Params.VegaLite
import Evergreen.V54.Pages.Admin
import Evergreen.V54.Pages.ElmUiSvgIssue
import Evergreen.V54.Pages.Home_
import Evergreen.V54.Pages.IncidentReports
import Evergreen.V54.Pages.Kimball
import Evergreen.V54.Pages.NotFound
import Evergreen.V54.Pages.Sheet
import Evergreen.V54.Pages.Stories.Basics
import Evergreen.V54.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V54.Pages.Stories.FirLang
import Evergreen.V54.Pages.Stories.TextEditor
import Evergreen.V54.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V54.Gen.Params.Admin.Params Evergreen.V54.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V54.Gen.Params.ElmUiSvgIssue.Params Evergreen.V54.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V54.Gen.Params.Home_.Params Evergreen.V54.Pages.Home_.Model
    | IncidentReports Evergreen.V54.Gen.Params.IncidentReports.Params Evergreen.V54.Pages.IncidentReports.Model
    | Kimball Evergreen.V54.Gen.Params.Kimball.Params Evergreen.V54.Pages.Kimball.Model
    | NotFound Evergreen.V54.Gen.Params.NotFound.Params Evergreen.V54.Pages.NotFound.Model
    | Sheet Evergreen.V54.Gen.Params.Sheet.Params Evergreen.V54.Pages.Sheet.Model
    | Stories Evergreen.V54.Gen.Params.Stories.Params
    | VegaLite Evergreen.V54.Gen.Params.VegaLite.Params Evergreen.V54.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V54.Gen.Params.Stories.Basics.Params Evergreen.V54.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V54.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V54.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V54.Gen.Params.Stories.FirLang.Params Evergreen.V54.Pages.Stories.FirLang.Model
    | Stories__TextEditor Evergreen.V54.Gen.Params.Stories.TextEditor.Params Evergreen.V54.Pages.Stories.TextEditor.Model
