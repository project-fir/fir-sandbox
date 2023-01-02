module Evergreen.V64.Gen.Model exposing (..)

import Evergreen.V64.Gen.Params.Admin
import Evergreen.V64.Gen.Params.ElmUiSvgIssue
import Evergreen.V64.Gen.Params.Home_
import Evergreen.V64.Gen.Params.IncidentReports
import Evergreen.V64.Gen.Params.Kimball
import Evergreen.V64.Gen.Params.NotFound
import Evergreen.V64.Gen.Params.Sheet
import Evergreen.V64.Gen.Params.Stories
import Evergreen.V64.Gen.Params.Stories.Basics
import Evergreen.V64.Gen.Params.Stories.DuckdbClient
import Evergreen.V64.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V64.Gen.Params.Stories.FirLang
import Evergreen.V64.Gen.Params.Stories.ProcessDag
import Evergreen.V64.Gen.Params.VegaLite
import Evergreen.V64.Pages.Admin
import Evergreen.V64.Pages.ElmUiSvgIssue
import Evergreen.V64.Pages.Home_
import Evergreen.V64.Pages.IncidentReports
import Evergreen.V64.Pages.Kimball
import Evergreen.V64.Pages.NotFound
import Evergreen.V64.Pages.Sheet
import Evergreen.V64.Pages.Stories.Basics
import Evergreen.V64.Pages.Stories.DuckdbClient
import Evergreen.V64.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V64.Pages.Stories.FirLang
import Evergreen.V64.Pages.Stories.ProcessDag
import Evergreen.V64.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V64.Gen.Params.Admin.Params Evergreen.V64.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V64.Gen.Params.ElmUiSvgIssue.Params Evergreen.V64.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V64.Gen.Params.Home_.Params Evergreen.V64.Pages.Home_.Model
    | IncidentReports Evergreen.V64.Gen.Params.IncidentReports.Params Evergreen.V64.Pages.IncidentReports.Model
    | Kimball Evergreen.V64.Gen.Params.Kimball.Params Evergreen.V64.Pages.Kimball.Model
    | NotFound Evergreen.V64.Gen.Params.NotFound.Params Evergreen.V64.Pages.NotFound.Model
    | Sheet Evergreen.V64.Gen.Params.Sheet.Params Evergreen.V64.Pages.Sheet.Model
    | Stories Evergreen.V64.Gen.Params.Stories.Params
    | VegaLite Evergreen.V64.Gen.Params.VegaLite.Params Evergreen.V64.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V64.Gen.Params.Stories.Basics.Params Evergreen.V64.Pages.Stories.Basics.Model
    | Stories__DuckdbClient Evergreen.V64.Gen.Params.Stories.DuckdbClient.Params Evergreen.V64.Pages.Stories.DuckdbClient.Model
    | Stories__EntityRelationshipDiagram Evergreen.V64.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V64.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V64.Gen.Params.Stories.FirLang.Params Evergreen.V64.Pages.Stories.FirLang.Model
    | Stories__ProcessDag Evergreen.V64.Gen.Params.Stories.ProcessDag.Params Evergreen.V64.Pages.Stories.ProcessDag.Model
