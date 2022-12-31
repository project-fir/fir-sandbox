module Evergreen.V62.Gen.Msg exposing (..)

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


type Msg
    = Admin Evergreen.V62.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V62.Pages.ElmUiSvgIssue.Msg
    | Home_ Evergreen.V62.Pages.Home_.Msg
    | IncidentReports Evergreen.V62.Pages.IncidentReports.Msg
    | Kimball Evergreen.V62.Pages.Kimball.Msg
    | NotFound Evergreen.V62.Pages.NotFound.Msg
    | Sheet Evergreen.V62.Pages.Sheet.Msg
    | VegaLite Evergreen.V62.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V62.Pages.Stories.Basics.Msg
    | Stories__DuckdbClient Evergreen.V62.Pages.Stories.DuckdbClient.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V62.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V62.Pages.Stories.FirLang.Msg
    | Stories__ProcessDag Evergreen.V62.Pages.Stories.ProcessDag.Msg
