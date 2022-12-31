module Evergreen.V63.Gen.Model exposing (..)

import Evergreen.V63.Gen.Params.Admin
import Evergreen.V63.Gen.Params.ElmUiSvgIssue
import Evergreen.V63.Gen.Params.Home_
import Evergreen.V63.Gen.Params.IncidentReports
import Evergreen.V63.Gen.Params.Kimball
import Evergreen.V63.Gen.Params.NotFound
import Evergreen.V63.Gen.Params.Sheet
import Evergreen.V63.Gen.Params.Stories
import Evergreen.V63.Gen.Params.Stories.Basics
import Evergreen.V63.Gen.Params.Stories.DuckdbClient
import Evergreen.V63.Gen.Params.Stories.EntityRelationshipDiagram
import Evergreen.V63.Gen.Params.Stories.FirLang
import Evergreen.V63.Gen.Params.Stories.ProcessDag
import Evergreen.V63.Gen.Params.VegaLite
import Evergreen.V63.Pages.Admin
import Evergreen.V63.Pages.ElmUiSvgIssue
import Evergreen.V63.Pages.Home_
import Evergreen.V63.Pages.IncidentReports
import Evergreen.V63.Pages.Kimball
import Evergreen.V63.Pages.NotFound
import Evergreen.V63.Pages.Sheet
import Evergreen.V63.Pages.Stories.Basics
import Evergreen.V63.Pages.Stories.DuckdbClient
import Evergreen.V63.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V63.Pages.Stories.FirLang
import Evergreen.V63.Pages.Stories.ProcessDag
import Evergreen.V63.Pages.VegaLite


type Model
    = Redirecting_
    | Admin Evergreen.V63.Gen.Params.Admin.Params Evergreen.V63.Pages.Admin.Model
    | ElmUiSvgIssue Evergreen.V63.Gen.Params.ElmUiSvgIssue.Params Evergreen.V63.Pages.ElmUiSvgIssue.Model
    | Home_ Evergreen.V63.Gen.Params.Home_.Params Evergreen.V63.Pages.Home_.Model
    | IncidentReports Evergreen.V63.Gen.Params.IncidentReports.Params Evergreen.V63.Pages.IncidentReports.Model
    | Kimball Evergreen.V63.Gen.Params.Kimball.Params Evergreen.V63.Pages.Kimball.Model
    | NotFound Evergreen.V63.Gen.Params.NotFound.Params Evergreen.V63.Pages.NotFound.Model
    | Sheet Evergreen.V63.Gen.Params.Sheet.Params Evergreen.V63.Pages.Sheet.Model
    | Stories Evergreen.V63.Gen.Params.Stories.Params
    | VegaLite Evergreen.V63.Gen.Params.VegaLite.Params Evergreen.V63.Pages.VegaLite.Model
    | Stories__Basics Evergreen.V63.Gen.Params.Stories.Basics.Params Evergreen.V63.Pages.Stories.Basics.Model
    | Stories__DuckdbClient Evergreen.V63.Gen.Params.Stories.DuckdbClient.Params Evergreen.V63.Pages.Stories.DuckdbClient.Model
    | Stories__EntityRelationshipDiagram Evergreen.V63.Gen.Params.Stories.EntityRelationshipDiagram.Params Evergreen.V63.Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Evergreen.V63.Gen.Params.Stories.FirLang.Params Evergreen.V63.Pages.Stories.FirLang.Model
    | Stories__ProcessDag Evergreen.V63.Gen.Params.Stories.ProcessDag.Params Evergreen.V63.Pages.Stories.ProcessDag.Model
