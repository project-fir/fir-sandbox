module Evergreen.V56.Gen.Model exposing (..)

import Evergreen.V56.Gen.Params.Admin
import Evergreen.V56.Gen.Params.ElmUiSvgIssue
import Evergreen.V56.Gen.Params.Home_
import Evergreen.V56.Gen.Params.IncidentReports
import Evergreen.V56.Gen.Params.Kimball
import Evergreen.V56.Gen.Params.NotFound
import Evergreen.V56.Gen.Params.Sheet
import Evergreen.V56.Gen.Params.Stories
import Evergreen.V56.Gen.Params.Stories.Basics
import Evergreen.V56.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V56.Gen.Params.Stories.FirLang
import Evergreen.V56.Gen.Params.Stories.TextEditor
import Evergreen.V56.Gen.Params.VegaLite
import Evergreen.V56.Pages.Admin
import Evergreen.V56.Pages.ElmUiSvgIssue
import Evergreen.V56.Pages.Home_
import Evergreen.V56.Pages.IncidentReports
import Evergreen.V56.Pages.Kimball
import Evergreen.V56.Pages.NotFound
import Evergreen.V56.Pages.Sheet
import Evergreen.V56.Pages.Stories.Basics
import Evergreen.V56.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V56.Pages.Stories.FirLang
import Evergreen.V56.Pages.Stories.TextEditor
import Evergreen.V56.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V56.Gen.Params.Admin.Params Evergreen.V56.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V56.Gen.Params.ElmUiSvgIssue.Params Evergreen.V56.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V56.Gen.Params.Home_.Params Evergreen.V56.Pages.Home_.Model
    | IncidentReports Evergreen.V56.Gen.Params.IncidentReports.Params Evergreen.V56.Pages.IncidentReports.Model
    | Kimball Evergreen.V56.Gen.Params.Kimball.Params Evergreen.V56.Pages.Kimball.Model
    | NotFound Evergreen.V56.Gen.Params.NotFound.Params Evergreen.V56.Pages.NotFound.Model
    | Sheet Evergreen.V56.Gen.Params.Sheet.Params Evergreen.V56.Pages.Sheet.Model
    | Stories Evergreen.V56.Gen.Params.Stories.Params
    | VegaLite Evergreen.V56.Gen.Params.VegaLite.Params Evergreen.V56.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V56.Gen.Params.Stories.Basics.Params Evergreen.V56.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V56.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V56.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V56.Gen.Params.Stories.FirLang.Params Evergreen.V56.Pages.Stories.FirLang.Model
    | Stories__TextEditor Evergreen.V56.Gen.Params.Stories.TextEditor.Params Evergreen.V56.Pages.Stories.TextEditor.Model
