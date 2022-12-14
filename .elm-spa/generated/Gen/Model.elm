module Gen.Model exposing (Model(..))

import Gen.Params.Admin
import Gen.Params.ElmUiSvgIssue
import Gen.Params.Home_
import Gen.Params.IncidentReports
import Gen.Params.Kimball
import Gen.Params.NotFound
import Gen.Params.Sheet
import Gen.Params.Stories
import Gen.Params.VegaLite
import Gen.Params.Stories.Basics
import Gen.Params.Stories.DuckdbClient
import Gen.Params.Stories.EntityRelationshipDiagram
import Gen.Params.Stories.FirLang
import Gen.Params.Stories.ProcessDag
import Pages.Admin
import Pages.ElmUiSvgIssue
import Pages.Home_
import Pages.IncidentReports
import Pages.Kimball
import Pages.NotFound
import Pages.Sheet
import Pages.Stories
import Pages.VegaLite
import Pages.Stories.Basics
import Pages.Stories.DuckdbClient
import Pages.Stories.EntityRelationshipDiagram
import Pages.Stories.FirLang
import Pages.Stories.ProcessDag


type Model
    = Redirecting_
    | Admin Gen.Params.Admin.Params Pages.Admin.Model
    | ElmUiSvgIssue Gen.Params.ElmUiSvgIssue.Params Pages.ElmUiSvgIssue.Model
    | Home_ Gen.Params.Home_.Params Pages.Home_.Model
    | IncidentReports Gen.Params.IncidentReports.Params Pages.IncidentReports.Model
    | Kimball Gen.Params.Kimball.Params Pages.Kimball.Model
    | NotFound Gen.Params.NotFound.Params Pages.NotFound.Model
    | Sheet Gen.Params.Sheet.Params Pages.Sheet.Model
    | Stories Gen.Params.Stories.Params
    | VegaLite Gen.Params.VegaLite.Params Pages.VegaLite.Model
    | Stories__Basics Gen.Params.Stories.Basics.Params Pages.Stories.Basics.Model
    | Stories__DuckdbClient Gen.Params.Stories.DuckdbClient.Params Pages.Stories.DuckdbClient.Model
    | Stories__EntityRelationshipDiagram Gen.Params.Stories.EntityRelationshipDiagram.Params Pages.Stories.EntityRelationshipDiagram.Model
    | Stories__FirLang Gen.Params.Stories.FirLang.Params Pages.Stories.FirLang.Model
    | Stories__ProcessDag Gen.Params.Stories.ProcessDag.Params Pages.Stories.ProcessDag.Model

