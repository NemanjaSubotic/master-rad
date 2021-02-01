module Registration exposing (..)

import Http
import Html exposing (Html, form, div, text, h4)
import Html.Attributes exposing (class, for, disabled, type_, required)
import Html.Events exposing (onSubmit)
import Json.Encode as Encode

import Material.Button as Button
import Material.TextField as TextField
import Material.Snackbar as Snackbar
import Material.Typography as Typography

import Util exposing (emptyHtmlNode, submitButton, progressLine)


type alias Model =
  { firstName: String
  , lastName: String
  , email: String
  , index: String
  , status: Maybe (Result Http.Error ())
  , processing: Bool
  , queue: Snackbar.Queue Msg 
  }

type Msg
  = Email String
  | Index String
  | FirstName String
  | LastName String
  | SubmittedForm
  | GotRegistrationResult (Result Http.Error ())
  | SnackbarClosed Snackbar.MessageId 

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    FirstName firstName -> ({model | firstName = firstName}, Cmd.none)
    LastName lastName -> ({model | lastName = lastName}, Cmd.none)
    Email email -> ({model | email = email}, Cmd.none)
    Index index -> ({model | index = index}, Cmd.none)
    SubmittedForm ->
      ( { model | status = Nothing, processing = True}, sendRequest model)

    GotRegistrationResult result -> 
      let 
        snackbarMessage text =
          Snackbar.message text
          |> Snackbar.setActionIcon (Just (Snackbar.icon "close"))
          |> Snackbar.setOnActionIconClick SnackbarClosed 

        setQueueMessage message =
          Snackbar.addMessage (snackbarMessage message) model.queue

        newModel = 
          case result of
            Ok _ -> { init | queue = setQueueMessage "Uspešno ste podneli prijavu!"}
            Err _ -> {model |  queue = setQueueMessage "Došlo je do neočekivane greške 😞"} 

      in ( { newModel | status = Just result, processing = False}, Cmd.none)

    SnackbarClosed messageId ->
      ({ model | queue = Snackbar.close messageId model.queue }, Cmd.none)
    

view : Model -> Html Msg
view model = 
  let
    formInput value label msg = 
      div [class "form-item"] 
        [TextField.outlined
          (TextField.config
              |> TextField.setLabel (Just label)
              |> TextField.setOnInput msg
              |> TextField.setAttributes [required True]
              |> TextField.setValue (Just value)
          )
        ]

    registerButton = 
      submitButton 
        { text = "Podnesi prijavu"
        , disabled = model.processing
        , icon = Just (Button.icon "person_add")
        }
  in
  div []
  [
    div [class "center"]
      [ form 
          [ onSubmit SubmittedForm
          , disabled model.processing
          ]
          [ h4 [Typography.headline5, class "heading"] [text "Podnesite zahtev za registraciju"]
          , formInput model.firstName "Ime" FirstName
          , formInput model.lastName "Prezime" LastName
          , formInput model.email "Email" Email
          , formInput model.index "Broj indeksa" Index
          , registerButton
          , progressLine model.processing  
          ]
      ]
      , Snackbar.snackbar
              (Snackbar.config { onClosed = SnackbarClosed })
              model.queue
  ]
  
  

init : Model
init =
  Model "" "" "" "" Nothing False Snackbar.initialQueue 

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