module Evergreen.V58.Gen.Msg exposing (..)

import Evergreen.V58.Pages.Admin
import Evergreen.V58.Pages.ElmUiSvgIssue
import Evergreen.V58.Pages.Home_
import Evergreen.V58.Pages.IncidentReports
import Evergreen.V58.Pages.Kimball
import Evergreen.V58.Pages.NotFound
import Evergreen.V58.Pages.Sheet
import Evergreen.V58.Pages.Stories.Basics
import Evergreen.V58.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V58.Pages.Stories.FirLang
import Evergreen.V58.Pages.Stories.TextEditor
import Evergreen.V58.Pages.VegaLite


type Msg
    = Admin Evergreen.V58.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V58.Pages.ElmUiSvgIssue.Msg
    | Home_ Evergreen.V58.Pages.Home_.Msg
    | IncidentReports Evergreen.V58.Pages.IncidentReports.Msg
    | Kimball Evergreen.V58.Pages.Kimball.Msg
    | NotFound Evergreen.V58.Pages.NotFound.Msg
    | Sheet Evergreen.V58.Pages.Sheet.Msg
    | VegaLite Evergreen.V58.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V58.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V58.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V58.Pages.Stories.FirLang.Msg
    | Stories__TextEditor Evergreen.V58.Pages.Stories.TextEditor.Msg
