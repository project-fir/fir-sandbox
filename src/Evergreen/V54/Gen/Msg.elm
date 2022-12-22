module Evergreen.V54.Gen.Msg exposing (..)

import Evergreen.V54.Pages.Admin
import Evergreen.V54.Pages.ElmUiSvgIssue
import Evergreen.V54.Pages.Home_
import Evergreen.V54.Pages.IncidentReports
import Evergreen.V54.Pages.Kimball
import Evergreen.V54.Pages.NotFound
import Evergreen.V54.Pages.Sheet
import Evergreen.V54.Pages.Stories.Basics
import Evergreen.V54.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V54.Pages.Stories.FirLang
import Evergreen.V54.Pages.Stories.TextEditor
import Evergreen.V54.Pages.VegaLite


type Msg
    = Admin Evergreen.V54.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V54.Pages.ElmUiSvgIssue.Msg
    | Home_ Evergreen.V54.Pages.Home_.Msg
    | IncidentReports Evergreen.V54.Pages.IncidentReports.Msg
    | Kimball Evergreen.V54.Pages.Kimball.Msg
    | NotFound Evergreen.V54.Pages.NotFound.Msg
    | Sheet Evergreen.V54.Pages.Sheet.Msg
    | VegaLite Evergreen.V54.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V54.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V54.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V54.Pages.Stories.FirLang.Msg
    | Stories__TextEditor Evergreen.V54.Pages.Stories.TextEditor.Msg
