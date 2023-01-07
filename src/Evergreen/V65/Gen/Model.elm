module Evergreen.V65.Gen.Model exposing (..)

import Evergreen.V65.Gen.Params.Admin
import Evergreen.V65.Gen.Params.ElmUiSvgIssue
import Evergreen.V65.Gen.Params.Home_
import Evergreen.V65.Gen.Params.IncidentReports
import Evergreen.V65.Gen.Params.Kimball
import Evergreen.V65.Gen.Params.NotFound
import Evergreen.V65.Gen.Params.Sheet
import Evergreen.V65.Gen.Params.Stories
import Evergreen.V65.Gen.Params.Stories.Basics
import Evergreen.V65.Gen.Params.Stories.DuckdbClient
import Evergreen.V65.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V65.Gen.Params.Stories.FirLang
import Evergreen.V65.Gen.Params.Stories.ProcessDag
import Evergreen.V65.Gen.Params.VegaLite
import Evergreen.V65.Pages.Admin
import Evergreen.V65.Pages.ElmUiSvgIssue
import Evergreen.V65.Pages.Home_
import Evergreen.V65.Pages.IncidentReports
import Evergreen.V65.Pages.Kimball
import Evergreen.V65.Pages.NotFound
import Evergreen.V65.Pages.Sheet
import Evergreen.V65.Pages.Stories.Basics
import Evergreen.V65.Pages.Stories.DuckdbClient
import Evergreen.V65.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V65.Pages.Stories.FirLang
import Evergreen.V65.Pages.Stories.ProcessDag
import Evergreen.V65.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V65.Gen.Params.Admin.Params Evergreen.V65.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V65.Gen.Params.ElmUiSvgIssue.Params Evergreen.V65.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V65.Gen.Params.Home_.Params Evergreen.V65.Pages.Home_.Model
    | IncidentReports Evergreen.V65.Gen.Params.IncidentReports.Params Evergreen.V65.Pages.IncidentReports.Model
    | Kimball Evergreen.V65.Gen.Params.Kimball.Params Evergreen.V65.Pages.Kimball.Model
    | NotFound Evergreen.V65.Gen.Params.NotFound.Params Evergreen.V65.Pages.NotFound.Model
    | Sheet Evergreen.V65.Gen.Params.Sheet.Params Evergreen.V65.Pages.Sheet.Model
    | Stories Evergreen.V65.Gen.Params.Stories.Params
    | VegaLite Evergreen.V65.Gen.Params.VegaLite.Params Evergreen.V65.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V65.Gen.Params.Stories.Basics.Params Evergreen.V65.Pages.Stories.Basics.Model
    | Stories__DuckdbClient Evergreen.V65.Gen.Params.Stories.DuckdbClient.Params Evergreen.V65.Pages.Stories.DuckdbClient.Model
    | Stories__EntityRelationshipDiagram Evergreen.V65.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V65.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V65.Gen.Params.Stories.FirLang.Params Evergreen.V65.Pages.Stories.FirLang.Model
    | Stories__ProcessDag Evergreen.V65.Gen.Params.Stories.ProcessDag.Params Evergreen.V65.Pages.Stories.ProcessDag.Model
