module Pages.Stories.ProcessDag exposing (Model, Msg, page)

import Effect exposing (Effect)
import Gen.Params.Stories.ProcessDag exposing (Params)
import Page
import Request
import Shared
import View exposing (View)
import Page


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


init : ( Model, Effect Msg )
init =
    ( {
    }, Effect.none )

-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    View.placeholder "Stories.ProcessDag"



"""
Process Dag

What do I mean by a process dag?

Ideally, it should be a model of a business process.

Let's use Smith's example of a pin factory, what are the things needed

 * Capital
 * Raw materials, mining
 * Miners
 * Raw materials, shipping to factory
 * Truckers
 * Labor in factory
 * The factory has design / stations
 * Shipments get sent to retail depot
 * Truckers from
 * customer buys in store
 * customers
 * store clerks

What are the facts and dimensions of this business process?

balance sheet - is this inferred?
mines
employees
payroll
raw materials
depot stock piles
distribution to retail depots
customers


 - dim_employee
   * employee_id, boomerangs get new row
   * of sub-dims: miner, factory worker, trucker, store clerks
   * name
   * dob
   * current_hourly_wage_usd - this could be a slowly-changing dimension
   * employment_depot
   * start_end
   * end_date


While I grouped all employees together in one dim table, I would think
there
 - dim_geo (let's be America-centric for now)
  * geo_id
  * state
  * city
  * region

 - dim_mine
  *

 - dim_factory
  *

 - dim_store
  *
 - dim_customers
 *

 - fact_mined_ore
  * mine_id
  * weight_us_tons
  * date


entities:
 * ore
 * employees
 * products
 * customers
 * money?

facts:
 * ore is mined
 * ore is shipped
 * ore is "cleansed", there's a better word for that
 * product is manufactured
 * product is shipped to store
 * product sells, maybe
 * product collect dust

















"""