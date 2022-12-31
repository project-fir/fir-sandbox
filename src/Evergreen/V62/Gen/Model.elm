module Evergreen.V62.Gen.Model exposing (..)

import Evergreen.V62.Gen.Params.Admin
import Evergreen.V62.Gen.Params.ElmUiSvgIssue
import Evergreen.V62.Gen.Params.Home_
import Evergreen.V62.Gen.Params.IncidentReports
import Evergreen.V62.Gen.Params.Kimball
import Evergreen.V62.Gen.Params.NotFound
import Evergreen.V62.Gen.Params.Sheet
import Evergreen.V62.Gen.Params.Stories
import Evergreen.V62.Gen.Params.Stories.Basics
import Evergreen.V62.Gen.Params.Stories.DuckdbClient
import Evergreen.V62.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V62.Gen.Params.Stories.FirLang
import Evergreen.V62.Gen.Params.Stories.ProcessDag
import Evergreen.V62.Gen.Params.VegaLite
import Evergreen.V62.Pages.Admin
import Evergreen.V62.Pages.ElmUiSvgIssue
import Evergreen.V62.Pages.Home_
import Evergreen.V62.Pages.IncidentReports
import Evergreen.V62.Pages.Kimball
import Evergreen.V62.Pages.NotFound
import Evergreen.V62.Pages.Sheet
import Evergreen.V62.Pages.Stories.Basics
import Evergreen.V62.Pages.Stories.DuckdbClient
import Evergreen.V62.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V62.Pages.Stories.FirLang
import Evergreen.V62.Pages.Stories.ProcessDag
import Evergreen.V62.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V62.Gen.Params.Admin.Params Evergreen.V62.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V62.Gen.Params.ElmUiSvgIssue.Params Evergreen.V62.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V62.Gen.Params.Home_.Params Evergreen.V62.Pages.Home_.Model
    | IncidentReports Evergreen.V62.Gen.Params.IncidentReports.Params Evergreen.V62.Pages.IncidentReports.Model
    | Kimball Evergreen.V62.Gen.Params.Kimball.Params Evergreen.V62.Pages.Kimball.Model
    | NotFound Evergreen.V62.Gen.Params.NotFound.Params Evergreen.V62.Pages.NotFound.Model
    | Sheet Evergreen.V62.Gen.Params.Sheet.Params Evergreen.V62.Pages.Sheet.Model
    | Stories Evergreen.V62.Gen.Params.Stories.Params
    | VegaLite Evergreen.V62.Gen.Params.VegaLite.Params Evergreen.V62.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V62.Gen.Params.Stories.Basics.Params Evergreen.V62.Pages.Stories.Basics.Model
    | Stories__DuckdbClient Evergreen.V62.Gen.Params.Stories.DuckdbClient.Params Evergreen.V62.Pages.Stories.DuckdbClient.Model
    | Stories__EntityRelationshipDiagram Evergreen.V62.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V62.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V62.Gen.Params.Stories.FirLang.Params Evergreen.V62.Pages.Stories.FirLang.Model
    | Stories__ProcessDag Evergreen.V62.Gen.Params.Stories.ProcessDag.Params Evergreen.V62.Pages.Stories.ProcessDag.Model
