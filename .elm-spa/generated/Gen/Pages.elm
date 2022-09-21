module Gen.Pages exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import ElmSpa.Page
import Gen.Params.Admin
import Gen.Params.Home_
import Gen.Params.Kimball
import Gen.Params.Sheet
import Gen.Params.VegaLite
import Gen.Params.NotFound
import Gen.Model as Model
import Gen.Msg as Msg
import Gen.Route as Route exposing (Route)
import Page exposing (Page)
import Pages.Admin
import Pages.Home_
import Pages.Kimball
import Pages.Sheet
import Pages.VegaLite
import Pages.NotFound
import Request exposing (Request)
import Shared
import Task
import Url exposing (Url)
import View exposing (View)


type alias Model =
    Model.Model


type alias Msg =
    Msg.Msg


init : Route -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
init route =
    case route of
        Route.Admin ->
            pages.admin.init ()
    
        Route.Home_ ->
            pages.home_.init ()
    
        Route.Kimball ->
            pages.kimball.init ()
    
        Route.Sheet ->
            pages.sheet.init ()
    
        Route.VegaLite ->
            pages.vegaLite.init ()
    
        Route.NotFound ->
            pages.notFound.init ()


update : Msg -> Model -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
update msg_ model_ =
    case ( msg_, model_ ) of
        ( Msg.Admin msg, Model.Admin params model ) ->
            pages.admin.update params msg model
    
        ( Msg.Kimball msg, Model.Kimball params model ) ->
            pages.kimball.update params msg model
    
        ( Msg.Sheet msg, Model.Sheet params model ) ->
            pages.sheet.update params msg model
    
        ( Msg.VegaLite msg, Model.VegaLite params model ) ->
            pages.vegaLite.update params msg model

        _ ->
            \_ _ _ -> ( model_, Effect.none )


view : Model -> Shared.Model -> Url -> Key -> View Msg
view model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> View.none
    
        Model.Admin params model ->
            pages.admin.view params model
    
        Model.Home_ params ->
            pages.home_.view params ()
    
        Model.Kimball params model ->
            pages.kimball.view params model
    
        Model.Sheet params model ->
            pages.sheet.view params model
    
        Model.VegaLite params model ->
            pages.vegaLite.view params model
    
        Model.NotFound params ->
            pages.notFound.view params ()


subscriptions : Model -> Shared.Model -> Url -> Key -> Sub Msg
subscriptions model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> Sub.none
    
        Model.Admin params model ->
            pages.admin.subscriptions params model
    
        Model.Home_ params ->
            pages.home_.subscriptions params ()
    
        Model.Kimball params model ->
            pages.kimball.subscriptions params model
    
        Model.Sheet params model ->
            pages.sheet.subscriptions params model
    
        Model.VegaLite params model ->
            pages.vegaLite.subscriptions params model
    
        Model.NotFound params ->
            pages.notFound.subscriptions params ()



-- INTERNALS


pages :
    { admin : Bundle Gen.Params.Admin.Params Pages.Admin.Model Pages.Admin.Msg
    , home_ : Static Gen.Params.Home_.Params
    , kimball : Bundle Gen.Params.Kimball.Params Pages.Kimball.Model Pages.Kimball.Msg
    , sheet : Bundle Gen.Params.Sheet.Params Pages.Sheet.Model Pages.Sheet.Msg
    , vegaLite : Bundle Gen.Params.VegaLite.Params Pages.VegaLite.Model Pages.VegaLite.Msg
    , notFound : Static Gen.Params.NotFound.Params
    }
pages =
    { admin = bundle Pages.Admin.page Model.Admin Msg.Admin
    , home_ = static Pages.Home_.view Model.Home_
    , kimball = bundle Pages.Kimball.page Model.Kimball Msg.Kimball
    , sheet = bundle Pages.Sheet.page Model.Sheet Msg.Sheet
    , vegaLite = bundle Pages.VegaLite.page Model.VegaLite Msg.VegaLite
    , notFound = static Pages.NotFound.view Model.NotFound
    }


type alias Bundle params model msg =
    ElmSpa.Page.Bundle params model msg Shared.Model (Effect Msg) Model Msg (View Msg)


bundle page toModel toMsg =
    ElmSpa.Page.bundle
        { redirecting =
            { model = Model.Redirecting_
            , view = View.none
            }
        , toRoute = Route.fromUrl
        , toUrl = Route.toHref
        , fromCmd = Effect.fromCmd
        , mapEffect = Effect.map toMsg
        , mapView = View.map toMsg
        , toModel = toModel
        , toMsg = toMsg
        , page = page
        }


type alias Static params =
    Bundle params () Never


static : View Never -> (params -> Model) -> Static params
static view_ toModel =
    { init = \params _ _ _ -> ( toModel params, Effect.none )
    , update = \params _ _ _ _ _ -> ( toModel params, Effect.none )
    , view = \_ _ _ _ _ -> View.map never view_
    , subscriptions = \_ _ _ _ _ -> Sub.none
    }
    
