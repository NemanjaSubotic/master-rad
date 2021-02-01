module Professor.RegistrationRequests exposing (Model, Msg, init, update, view, loadRequests)

import Http
import Html exposing (Html, text, ul, li, div, h6, span, strong)
import Html.Attributes exposing (class, for, disabled, type_)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Json.Decode exposing (Decoder, map, map6, field, int, string, list )
import Util exposing (emptyHtmlNode)
import Html.Attributes exposing (style)
import Json.Decode.Pipeline exposing (custom)

import Material.Tab as MTab
import Material.TabBar as MTabBar
import Material.List as MList
import Material.List.Item as MListItem
import Material.IconButton as IconButton
import Material.Icon as MIcon
import Material.CircularProgress as CircularProgress

import Api

statusAccepted : String
statusAccepted = "accepted"
statusRejected : String
statusRejected = "rejected"
statusPending : String
statusPending = "pending"

type alias Model =
  { acceptedRequests : List RegistrationRequest
  , rejectedRequests : List RegistrationRequest
  , pendingRequests : List RegistrationRequest
  , processingRequests : List (Int, Bool)
  , tab : Tab
  , isInitialized : Bool
  }

type alias RegistrationRequest =
  { id : Int 
  , firstName : String
  , lastName : String
  , email : String
  , index : String
  , status : String
  }

type Tab 
  = Pending
  | Accepted
  | Rejected  


type Msg
  = GotLoadingResult (Result Http.Error (List RegistrationRequest))
  | AcceptRequest Int
  | RejecteRequest Int
  | StatusChanged (Result Http.Error RegistrationRequest)
  | TabClicked Tab

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

loadRequests : String -> Cmd Msg
loadRequests token =
  Http.request
    { method = "GET"
    , headers = [Api.authHeader token]
    , url = "http://localhost:4000/api/registrations"
    , body = Http.emptyBody
    , expect = Http.expectJson GotLoadingResult requestsListDecoder 
    , timeout = Nothing
    , tracker = Nothing
    }

update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
  case msg of
    GotLoadingResult result ->
      case result of
        Ok data -> ( processData model data , Cmd.none)
        Err _ -> (model, Cmd.none)

    AcceptRequest id -> 
      ( { model | processingRequests = (id, True) :: model.processingRequests}
      , updateRequestStatus id statusAccepted token
      )

    RejecteRequest id -> 
      ( { model | processingRequests = (id, False) :: model.processingRequests}
      , updateRequestStatus id statusRejected token
      )

    StatusChanged result -> 
      case result of
        Ok req -> 
           ( changeStatus model req, Cmd.none)
        Err _ -> (model, Cmd.none)
        
    TabClicked tab -> ({ model | tab = tab}, Cmd.none)

processData : Model -> List RegistrationRequest -> Model
processData model data =  
  let
    acceptedRequests = List.filter (\x -> x.status == statusAccepted ) data
    rejectedRequests = List.filter (\x -> x.status == statusRejected ) data
    pendingRequests = List.filter (\x -> x.status == statusPending ) data
  in
    { model | rejectedRequests = rejectedRequests
    , acceptedRequests = acceptedRequests
    , pendingRequests = pendingRequests
    , isInitialized = True
    }

changeStatus : Model -> RegistrationRequest -> Model
changeStatus model request = 
  let
    pendingRequests = List.filter (\x -> x.id /= request.id ) model.pendingRequests
    processingRequests = List.filter (\(id, _) -> id /= request.id) model.processingRequests
  in
    if request.status == statusAccepted then
      { model | pendingRequests = pendingRequests
      , acceptedRequests = request :: model.acceptedRequests
      , processingRequests = processingRequests
      }
    else
      { model | pendingRequests = pendingRequests
      , rejectedRequests = request :: model.rejectedRequests
      , processingRequests = processingRequests
      }

tabBar : Model -> Html Msg
tabBar model =
  let
    isActive tab =
      tab == model.tab
    tabLabel tab = 
      case tab of
        Pending -> "Na čekanju"
        Accepted -> "Prihvaćeni"
        Rejected -> "Odbijeni"

    createTab tab = 
      MTab.tab
      (MTab.config
        |> MTab.setActive (isActive tab)
        |> MTab.setOnClick (TabClicked tab)
      )
      { label = (tabLabel tab), icon = Nothing }
  in
    MTabBar.tabBar MTabBar.config
        [ createTab Pending
        , createTab Accepted
        , createTab Rejected
        ]

view : Model -> Html Msg
view model =
  let
      (data, noDataMsg) =  
        case model.tab of
          Accepted -> (model.acceptedRequests, "Nema prihvaćenih zahteva")
          Pending -> (model.pendingRequests, "Nema novih zahteva")
          Rejected -> (model.rejectedRequests, "Nema odbijenih zahteva")

      iconButton icon cmd =
        IconButton.iconButton
          (IconButton.config |> IconButton.setOnClick cmd)
          (IconButton.icon icon)
      
      spinnerWithIcon : String -> Html Msg
      spinnerWithIcon icon  = 
        div [class "spinnerWithIcon"]
        [ div [class "center"] [CircularProgress.indeterminate CircularProgress.config]
        , MListItem.graphic [class "center"] [ MIcon.icon [] icon ]
        ]

      listItemMetaContent : Int -> List (Html Msg)
      listItemMetaContent id =
        let
          pocessingPair = List.filter (\(i, _) -> i == id) model.processingRequests
        in
        case (model.tab, pocessingPair) of
          ( Pending, [] ) -> 
            [ iconButton "check" (AcceptRequest id), iconButton "close" (RejecteRequest id)]
          ( Pending, [(_, status)]) -> 
            [ spinnerWithIcon (if status then "check" else "close") ]
          _ -> []

      listItemView : RegistrationRequest -> MListItem.ListItem Msg
      listItemView {id, firstName, lastName, index} =
        MListItem.listItem MListItem.config
          [ MListItem.graphic [] [ MIcon.icon [] "account_box" ]
          , text  <| firstName ++ " " ++ lastName ++ " " ++ index
          , MListItem.meta [] (listItemMetaContent id)
          ]

      content = 
        case data of
          head :: tail ->
            MList.list MList.config (listItemView head) (List.map listItemView tail)
          _ -> 
            text noDataMsg
  in
  div []
  [ tabBar model
  , content    
  ]
 

init : Model
init =
  Model [] [] [] [] Pending False

updateRequestStatus : Int -> String -> String -> Cmd Msg
updateRequestStatus id status token =
  let
      body = 
        Encode.object
          [ ("registration"
            , Encode.object 
                [("status", Encode.string status)]) 
          ]

      headers = [Api.authHeader token]
        
  in
  Http.request
    { method = "PATCH"
    , headers = headers
    , url = "http://localhost:4000/api/registrations/" ++ String.fromInt id
    , body = Http.jsonBody body
    , expect = Http.expectJson StatusChanged (field "data" requestDecoder)
    , timeout = Nothing
    , tracker = Nothing
    }
