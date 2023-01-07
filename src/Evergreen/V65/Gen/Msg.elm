module Evergreen.V65.Gen.Msg exposing (..)

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


type Msg
    = Admin Evergreen.V65.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V65.Pages.ElmUiSvgIssue.Msg
    | Home_ Evergreen.V65.Pages.Home_.Msg
    | IncidentReports Evergreen.V65.Pages.IncidentReports.Msg
    | Kimball Evergreen.V65.Pages.Kimball.Msg
    | NotFound Evergreen.V65.Pages.NotFound.Msg
    | Sheet Evergreen.V65.Pages.Sheet.Msg
    | VegaLite Evergreen.V65.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V65.Pages.Stories.Basics.Msg
    | Stories__DuckdbClient Evergreen.V65.Pages.Stories.DuckdbClient.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V65.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V65.Pages.Stories.FirLang.Msg
    | Stories__ProcessDag Evergreen.V65.Pages.Stories.ProcessDag.Msg
