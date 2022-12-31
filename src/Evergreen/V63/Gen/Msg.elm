module Evergreen.V63.Gen.Msg exposing (..)

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


type Msg
    = Admin Evergreen.V63.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V63.Pages.ElmUiSvgIssue.Msg
    | Home_ Evergreen.V63.Pages.Home_.Msg
    | IncidentReports Evergreen.V63.Pages.IncidentReports.Msg
    | Kimball Evergreen.V63.Pages.Kimball.Msg
    | NotFound Evergreen.V63.Pages.NotFound.Msg
    | Sheet Evergreen.V63.Pages.Sheet.Msg
    | VegaLite Evergreen.V63.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V63.Pages.Stories.Basics.Msg
    | Stories__DuckdbClient Evergreen.V63.Pages.Stories.DuckdbClient.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V63.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V63.Pages.Stories.FirLang.Msg
    | Stories__ProcessDag Evergreen.V63.Pages.Stories.ProcessDag.Msg
