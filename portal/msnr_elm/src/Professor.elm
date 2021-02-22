module Professor exposing (..)

import Professor.RegistrationRequests as Requests
import Url.Parser as Parser exposing ((</>), Parser, s)
import Html exposing (Html, text)

type alias Model =
  { currentPage: Page
  , requstesModel: Requests.Model
  }

type Page
  = RegistrationRequestsPage
  | SettingsPage

type Route
  = RegistrationRequestsRoute
  | SettingsRoute

routeToString : Route -> String
routeToString route = 
  case route of
    RegistrationRequestsRoute -> "/registrations"
    SettingsRoute -> "/settings"

pageFromRoute: Route -> Page
pageFromRoute route =
  case route of
    RegistrationRequestsRoute -> RegistrationRequestsPage
    SettingsRoute -> SettingsPage

routeParser : Parser (Route -> a) a
routeParser = 
  Parser.oneOf 
  [ Parser.map RegistrationRequestsRoute (s "registrations")
  , Parser.map SettingsRoute (s "settings") 
  ]

type Msg
  = GotRequestsMsg Requests.Msg
  | GotSettingsMsg

view : Model -> Html Msg
view model =
  case model.currentPage of
    RegistrationRequestsPage -> 
      Requests.view model.requstesModel |> Html.map GotRequestsMsg
    
    SettingsPage -> text "Settings"

update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
  case (msg, model.currentPage) of 
    (GotRequestsMsg reqMsg, RegistrationRequestsPage)  -> 
      let
        (reqModel, cmd) = Requests.update reqMsg model.requstesModel token
      in
        ( {model | requstesModel = reqModel}
        , Cmd.map GotRequestsMsg cmd)
    _ -> ( model, Cmd.none)


init : Model
init =
  Model RegistrationRequestsPage Requests.init

initCmd : String -> Model -> Cmd Msg
initCmd token model = Debug.log (Debug.toString model) <|
  if model.requstesModel.isInitialized then 
    Cmd.none
  else
    Requests.loadRequests token |>  Cmd.map GotRequestsMsg

navIcons : List {icon : String, route: Route}
navIcons = 
  [ {icon = "group_add", route = RegistrationRequestsRoute}
  , {icon = "settings", route = SettingsRoute}
  ]