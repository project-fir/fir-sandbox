module Evergreen.V61.Gen.Model exposing (..)

import Evergreen.V61.Gen.Params.Admin
import Evergreen.V61.Gen.Params.ElmUiSvgIssue
import Evergreen.V61.Gen.Params.Home_
import Evergreen.V61.Gen.Params.IncidentReports
import Evergreen.V61.Gen.Params.Kimball
import Evergreen.V61.Gen.Params.NotFound
import Evergreen.V61.Gen.Params.Sheet
import Evergreen.V61.Gen.Params.Stories
import Evergreen.V61.Gen.Params.Stories.Basics
import Evergreen.V61.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V61.Gen.Params.Stories.FirLang
import Evergreen.V61.Gen.Params.Stories.ProcessDag
import Evergreen.V61.Gen.Params.Stories.TextEditor
import Evergreen.V61.Gen.Params.VegaLite
import Evergreen.V61.Pages.Admin
import Evergreen.V61.Pages.ElmUiSvgIssue
import Evergreen.V61.Pages.Home_
import Evergreen.V61.Pages.IncidentReports
import Evergreen.V61.Pages.Kimball
import Evergreen.V61.Pages.NotFound
import Evergreen.V61.Pages.Sheet
import Evergreen.V61.Pages.Stories.Basics
import Evergreen.V61.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V61.Pages.Stories.FirLang
import Evergreen.V61.Pages.Stories.ProcessDag
import Evergreen.V61.Pages.Stories.TextEditor
import Evergreen.V61.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V61.Gen.Params.Admin.Params Evergreen.V61.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V61.Gen.Params.ElmUiSvgIssue.Params Evergreen.V61.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V61.Gen.Params.Home_.Params Evergreen.V61.Pages.Home_.Model
    | IncidentReports Evergreen.V61.Gen.Params.IncidentReports.Params Evergreen.V61.Pages.IncidentReports.Model
    | Kimball Evergreen.V61.Gen.Params.Kimball.Params Evergreen.V61.Pages.Kimball.Model
    | NotFound Evergreen.V61.Gen.Params.NotFound.Params Evergreen.V61.Pages.NotFound.Model
    | Sheet Evergreen.V61.Gen.Params.Sheet.Params Evergreen.V61.Pages.Sheet.Model
    | Stories Evergreen.V61.Gen.Params.Stories.Params
    | VegaLite Evergreen.V61.Gen.Params.VegaLite.Params Evergreen.V61.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V61.Gen.Params.Stories.Basics.Params Evergreen.V61.Pages.Stories.Basics.Model
    | Stories__EntityRelationshipDiagram Evergreen.V61.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V61.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V61.Gen.Params.Stories.FirLang.Params Evergreen.V61.Pages.Stories.FirLang.Model
    | Stories__ProcessDag Evergreen.V61.Gen.Params.Stories.ProcessDag.Params Evergreen.V61.Pages.Stories.ProcessDag.Model
    | Stories__TextEditor Evergreen.V61.Gen.Params.Stories.TextEditor.Params Evergreen.V61.Pages.Stories.TextEditor.Model
