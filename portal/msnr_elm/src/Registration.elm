module Registration exposing (..)

import Http
import Html exposing (Html, text, h4)
import Html.Attributes exposing (class, for, disabled, type_)
import Html.Events exposing (onSubmit)
import Json.Encode as Encode
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Bootstrap.Alert as Alert
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import Util exposing (emptyHtmlNode)

type alias Model =
  { firstName: String
  , lastName: String
  , email: String
  , index: String
  , status: Maybe (Result Http.Error ())
  , processing: Bool
  }

type Msg
  = Email String
  | Index String
  | FirstName String
  | LastName String
  | SubmittedForm
  | GotRegistrationResult (Result Http.Error ())

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    FirstName firstName -> ({model | firstName = firstName}, Cmd.none)
    LastName lastName -> ({model | lastName = lastName}, Cmd.none)
    Email email -> ({model | email = email}, Cmd.none)
    Index index -> ({model | index = index}, Cmd.none)
    SubmittedForm -> ( { model | status = Nothing, processing = True}, sendRequest model)
    GotRegistrationResult result -> 
      let 
        newModel = 
          case result of
            Ok _ -> init
            Err _ -> model
      in ( { newModel | status = Just result, processing = False}, Cmd.none)
    
view : Model -> Html Msg
view model = 
  let
    alert = 
      case model.status of
        Just (Err _) -> Alert.simpleDanger [] [text "Došlo je do neočekivane greške 😞"]
        Just (Ok _)  -> Alert.simpleInfo [] [text "Uspešno ste podneli prijavu!"]
        Nothing -> emptyHtmlNode
    registerButton = 
      if model.processing then
        Button.button
          [ Button.primary, Button.disabled True, Button.attrs [ Spacing.mr3 ] ]
          [ Spinner.spinner
              [ Spinner.small, Spinner.attrs [ Spacing.mr1 ] ] []
          , text "Slanje prijave..."
          ]
      else
        Button.submitButton [ Button.primary] [text "Podnesi prijavu"]
  in
  Form.form 
    [ class "mt-3 mx-auto loginForm"
    , onSubmit SubmittedForm
    , disabled model.processing
    ]
    [ h4 [] [text "Pošaljite zahtev za registraciju"]
    , alert
    , Form.group []
      [ Form.label [for "firstName" ] [text "Ime"]
      , Input.text 
        [ Input.id "firstName"
        , Input.onInput FirstName
        , Input.value model.firstName
        ]
      ]
    , Form.group []
      [ Form.label [for "lastName" ] [text "Prezime"]
      , Input.text 
        [ Input.id "lastName"
        , Input.onInput LastName
        , Input.value model.lastName
        ]
      ]
    , Form.group []
      [ Form.label [for "email" ] [text "Email"]
      , Input.email 
        [ Input.id "email"
        , Input.onInput Email
        , Input.value model.email
        ]
      ]  
    , Form.group []
      [ Form.label [for "index" ] [text "Broj indeksa"]
      , Input.text 
        [ Input.id "index"
        , Input.onInput Index
        , Input.value model.index
        ]
      ]
    , registerButton  
    ]

init : Model
init =
  Model "" "" "" "" Nothing False

sendRequest : Model -> Cmd Msg
sendRequest model=
  let
    body =
      Encode.object 
        [ ("registration" 
          , Encode.object
            [ ("email", Encode.string model.email)
            , ("index_number", Encode.string model.index)
            , ("first_name", Encode.string model.firstName)
            , ("last_name", Encode.string model.lastName)
            ]
          )
        ]
  in
  Http.post 
  { url = "http://localhost:4000/api/registrations"
  , body = Http.jsonBody body
  , expect = Http.expectWhatever GotRegistrationResult
  }