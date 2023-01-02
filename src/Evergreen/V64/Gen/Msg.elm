module Evergreen.V64.Gen.Msg exposing (..)

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


type Msg
    = Admin Evergreen.V64.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V64.Pages.ElmUiSvgIssue.Msg
    | Home_ Evergreen.V64.Pages.Home_.Msg
    | IncidentReports Evergreen.V64.Pages.IncidentReports.Msg
    | Kimball Evergreen.V64.Pages.Kimball.Msg
    | NotFound Evergreen.V64.Pages.NotFound.Msg
    | Sheet Evergreen.V64.Pages.Sheet.Msg
    | VegaLite Evergreen.V64.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V64.Pages.Stories.Basics.Msg
    | Stories__DuckdbClient Evergreen.V64.Pages.Stories.DuckdbClient.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V64.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V64.Pages.Stories.FirLang.Msg
    | Stories__ProcessDag Evergreen.V64.Pages.Stories.ProcessDag.Msg
