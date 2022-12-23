module Evergreen.V56.Gen.Msg exposing (..)

import Evergreen.V56.Pages.Admin
import Evergreen.V56.Pages.ElmUiSvgIssue
import Evergreen.V56.Pages.Home_
import Evergreen.V56.Pages.IncidentReports
import Evergreen.V56.Pages.Kimball
import Evergreen.V56.Pages.NotFound
import Evergreen.V56.Pages.Sheet
import Evergreen.V56.Pages.Stories.Basics
import Evergreen.V56.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V56.Pages.Stories.FirLang
import Evergreen.V56.Pages.Stories.TextEditor
import Evergreen.V56.Pages.VegaLite


type Msg
    = Admin Evergreen.V56.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V56.Pages.ElmUiSvgIssue.Msg
    | Home_ Evergreen.V56.Pages.Home_.Msg
    | IncidentReports Evergreen.V56.Pages.IncidentReports.Msg
    | Kimball Evergreen.V56.Pages.Kimball.Msg
    | NotFound Evergreen.V56.Pages.NotFound.Msg
    | Sheet Evergreen.V56.Pages.Sheet.Msg
    | VegaLite Evergreen.V56.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V56.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V56.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V56.Pages.Stories.FirLang.Msg
    | Stories__TextEditor Evergreen.V56.Pages.Stories.TextEditor.Msg
