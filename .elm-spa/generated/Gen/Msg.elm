module Gen.Msg exposing (Msg(..))

import Gen.Params.Admin
import Gen.Params.ElmUiSvgIssue
import Gen.Params.Home_
import Gen.Params.Kimball
import Gen.Params.NotFound
import Gen.Params.Sheet
import Gen.Params.Stories
import Gen.Params.VegaLite
import Gen.Params.Stories.Basics
import Gen.Params.Stories.EntityRelationshipDiagram
import Gen.Params.Stories.FirLang
import Gen.Params.Stories.TextEditor
import Pages.Admin
import Pages.ElmUiSvgIssue
import Pages.Home_
import Pages.Kimball
import Pages.NotFound
import Pages.Sheet
import Pages.Stories
import Pages.VegaLite
import Pages.Stories.Basics
import Pages.Stories.EntityRelationshipDiagram
import Pages.Stories.FirLang
import Pages.Stories.TextEditor


type Msg
    = Admin Pages.Admin.Msg
    | ElmUiSvgIssue Pages.ElmUiSvgIssue.Msg
    | Home_ Pages.Home_.Msg
    | Kimball Pages.Kimball.Msg
    | Sheet Pages.Sheet.Msg
    | VegaLite Pages.VegaLite.Msg
    | Stories__Basics Pages.Stories.Basics.Msg
    | Stories__EntityRelationshipDiagram Pages.Stories.EntityRelationshipDiagram.Msg
    | Stories__FirLang Pages.Stories.FirLang.Msg
    | Stories__TextEditor Pages.Stories.TextEditor.Msg

