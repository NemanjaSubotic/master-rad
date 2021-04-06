module Professor exposing (..)

import Professor.RegistrationRequests as Requests
import Professor.Settings as Settings 
import Url.Parser as Parser exposing ((</>), Parser, s)
import Html exposing (Html)

type alias Model =
  { requstesModel: Requests.Model
  , settingModel: Settings.Model
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
  | GotSettingsMsg Settings.Msg

view : Model -> Page -> Html Msg
view model page =
  case page of
    RegistrationRequestsPage -> 
      Requests.view model.requstesModel |> Html.map GotRequestsMsg
    
    SettingsPage -> 
      Settings.view model.settingModel |> Html.map GotSettingsMsg

update : Msg -> Model -> String -> Page -> ( Model, Cmd Msg )
update msg model token _ =
  case msg of 
    GotRequestsMsg reqMsg  -> 
      let
        (model_, cmd) = Requests.update reqMsg model.requstesModel token
      in
        ( {model | requstesModel = model_}, Cmd.map GotRequestsMsg cmd)
   
    GotSettingsMsg settingsMsg ->
        let
          (model_, cmd) = Settings.update settingsMsg model.settingModel token
        in
          ( {model | settingModel = model_}, Cmd.map GotSettingsMsg cmd)


init : Model
init =
  Model Requests.init Settings.init

initCmd : String -> Model -> Route -> Cmd Msg
initCmd token model route =
  case route of
    RegistrationRequestsRoute -> 
      if model.requstesModel.isInitialized then 
        Cmd.none
      else
        Requests.loadRequests token |>  Cmd.map GotRequestsMsg

    SettingsRoute -> 
      Settings.initCmd model.settingModel token  |> Cmd.map GotSettingsMsg
navIcons : List {icon : String, route: Route}
navIcons = 
  [ {icon = "group_add", route = RegistrationRequestsRoute}
  , {icon = "settings", route = SettingsRoute}
  ]