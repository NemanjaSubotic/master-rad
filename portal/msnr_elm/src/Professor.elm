module Professor exposing (..)

import Http
import Html exposing (Html, text, ul, li, div, h6, span, strong)
import Html.Attributes exposing (class, for, disabled, type_)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Bootstrap.Card as Card
import Bootstrap.Button as Button
import Bootstrap.Alert as Alert
import Bootstrap.Spinner as Spinner
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Utilities.Spacing as Spacing
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Json.Decode exposing (Decoder, map, map6, field, int, string, list )
import Util exposing (emptyHtmlNode)
import Html.Attributes exposing (style)
import Json.Decode.Pipeline exposing (custom)

statusAccepted : String
statusAccepted = "accepted"
statusRejected : String
statusRejected = "rejected"

statusPending : String
statusPending = "pending"

type alias Model =
  { data : List RegistrationRequest
  }

type alias RegistrationRequest =
    { id : Int 
    , firstName : String
    , lastName : String
    , email : String
    , index : String
    , status : String
    }

type Msg
  = GotLoadingResult (Result Http.Error (List RegistrationRequest))
  | AcceptRequest Int
  | RejecteRequest Int
  | StatusChanged (Result Http.Error RegistrationRequest)

requestsListDecoder : Decoder (List RegistrationRequest)
requestsListDecoder = 
  field "data" (list requestDecoder)

requestDecoder : Decoder RegistrationRequest
requestDecoder =
  map6 RegistrationRequest
  (field "id" int)
  (field "first_name" string)
  (field "last_name" string)
  (field "email" string)
  (field "index_number" string)
  (field "status" string)

loadRequests : Cmd Msg
loadRequests = 
  Http.get
    { url = "http://localhost:4000/api/registrations"
    , expect = Http.expectJson GotLoadingResult requestsListDecoder 
    }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GotLoadingResult result ->
      case result of
        Ok data -> ({model | data = data }, Cmd.none)
        Err _ -> Debug.log "greksa" (model, Cmd.none)
    AcceptRequest id -> (model, updateRequestStatus id statusAccepted)
    RejecteRequest id -> (model, updateRequestStatus id statusRejected)
    StatusChanged result -> 
      case result of
        Ok req -> 
          let
              updateChangedStatus x =
                if x.id == req.id then {x | status = req.status} 
                else x
          in
          Debug.log "StatusChanged" ({model | data = List.map updateChangedStatus model.data}, Cmd.none)
        Err _ -> Debug.log "greksa" (model, Cmd.none)
      
    
view : Model -> Html Msg
view model =
  let
      data =  List.filter (\x -> x.status == statusPending) model.data
  in
  Card.config []
  |> Card.listGroup (List.map requestView data)
  |> Card.view

requestView : RegistrationRequest -> ListGroup.Item Msg
requestView req =
  ListGroup.li [] 
  [ Grid.container []
      [ Grid.row [] 
        [ Grid.col [] 
          [ strong [style "display" "block"] [ text <| req.firstName ++ " " ++ req.lastName ++ " " ++ req.index]
          , span [] [text req.email]
          ]
        , Grid.col [ Col.attrs [style "text-align" "end"]] 
          [ Button.button 
            [ Button.success
            , Button.attrs[ Spacing.mr1]
            , Button.onClick (AcceptRequest req.id)
            ]  
            [text "Prihvati"]
          , Button.button [Button.danger, Button.onClick (RejecteRequest req.id)]  [text "Odbaci"]
          ]
        ]
      ]
  ]

init : Model
init =
  Model []

updateRequestStatus : Int -> String -> Cmd Msg
updateRequestStatus id status =
  let
      body = 
        Encode.object
          [ ("registration"
            , Encode.object 
                [("status", Encode.string status)]) 
          ]  
  in
  Http.request
    { method = "PATCH"
    , headers = []
    , url = "http://localhost:4000/api/registrations/" ++ String.fromInt id
    , body = Http.jsonBody body
    , expect = Http.expectJson StatusChanged (field "data" requestDecoder)
    , timeout = Nothing
    , tracker = Nothing
    }
    

