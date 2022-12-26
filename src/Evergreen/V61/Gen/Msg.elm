module Evergreen.V61.Gen.Msg exposing (..)

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


type Msg
    = Admin Evergreen.V61.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V61.Pages.ElmUiSvgIssue.Msg
    | Home_ Evergreen.V61.Pages.Home_.Msg
    | IncidentReports Evergreen.V61.Pages.IncidentReports.Msg
    | Kimball Evergreen.V61.Pages.Kimball.Msg
    | NotFound Evergreen.V61.Pages.NotFound.Msg
    | Sheet Evergreen.V61.Pages.Sheet.Msg
    | VegaLite Evergreen.V61.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V61.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V61.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V61.Pages.Stories.FirLang.Msg
    | Stories__ProcessDag Evergreen.V61.Pages.Stories.ProcessDag.Msg
    | Stories__TextEditor Evergreen.V61.Pages.Stories.TextEditor.Msg
