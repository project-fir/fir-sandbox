module Evergreen.V52.Gen.Msg exposing (..)

import Evergreen.V52.Pages.Admin
import Evergreen.V52.Pages.ElmUiSvgIssue
import Evergreen.V52.Pages.Home_
import Evergreen.V52.Pages.Kimball
import Evergreen.V52.Pages.NotFound
import Evergreen.V52.Pages.Sheet
import Evergreen.V52.Pages.Stories.Basics
import Evergreen.V52.Pages.Stories.EntityRelationshipDiagram
import Evergreen.V52.Pages.Stories.FirLang
import Evergreen.V52.Pages.Stories.TextEditor
import Evergreen.V52.Pages.VegaLite


type Msg
    = Admin Evergreen.V52.Pages.Admin.Msg
    | ElmUiSvgIssue Evergreen.V52.Pages.ElmUiSvgIssue.Msg
    | Home_ Evergreen.V52.Pages.Home_.Msg
    | Kimball Evergreen.V52.Pages.Kimball.Msg
    | NotFound Evergreen.V52.Pages.NotFound.Msg
    | Sheet Evergreen.V52.Pages.Sheet.Msg
    | VegaLite Evergreen.V52.Pages.VegaLite.Msg
    | Stories__Basics Evergreen.V52.Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Evergreen.V52.Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Evergreen.V52.Pages.Stories.FirLang.Msg
    | Stories__TextEditor Evergreen.V52.Pages.Stories.TextEditor.Msg
