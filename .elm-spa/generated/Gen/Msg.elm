module Gen.Msg exposing (Msg(..))

import Gen.Params.Admin
import Gen.Params.ElmUiSvgIssue
import Gen.Params.Home_
import Gen.Params.Kimball
import Gen.Params.Sheet
import Gen.Params.Stories
import Gen.Params.VegaLite
import Gen.Params.Stories.Basics
import Gen.Params.NotFound
import Pages.Admin
import Pages.ElmUiSvgIssue
import Pages.Home_
import Pages.Kimball
import Pages.Sheet
import Pages.Stories
import Pages.VegaLite
import Pages.Stories.Basics
import Pages.NotFound


type Msg
    = Admin Pages.Admin.Msg
    | ElmUiSvgIssue Pages.ElmUiSvgIssue.Msg
    | Kimball Pages.Kimball.Msg
    | Sheet Pages.Sheet.Msg
    | VegaLite Pages.VegaLite.Msg
    | Stories__Basics Pages.Stories.Basics.Msg

