module SetPassword exposing (..)

import Html exposing (Html, text, h4)
import Html.Attributes exposing (class, for, disabled, classList, required)
import Html.Events exposing (onSubmit)
import Professor exposing (requestDecoder)
import Json.Decode exposing (field, int)
import Json.Encode as Encode
import Http

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Bootstrap.Alert as Alert
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import Http exposing (emptyBody)
import Util exposing (emptyHtmlNode)
import User.Session as Session

type alias Model =
  { userId: Maybe Int
  , email: String
  , password: String
  , confirmPassword: String
  , processing: Bool
  }

type Msg
  = Email String
  | Password String
  | ConfirmPassword String
  | SubmittedForm
  | GotLoadingResult (Result Http.Error Int)
  | GotSetPasswordResult (Result Http.Error ())
  | SessionMsg Session.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Email email -> ({model | email = email}, Cmd.none)
    Password password -> ({model | password = password}, Cmd.none)
    ConfirmPassword password -> ({model | confirmPassword = password}, Cmd.none)
    SubmittedForm -> ({ model | processing = True }, setPassword model)
    -- SubmittedForm -> ( { model | status = Nothing, processing = True}, sendRequest model)
    GotLoadingResult result -> 
      case result of
        Ok userId -> Debug.log "GotLoadingResult" ({model | userId = Just userId}, Cmd.none)
        Err error -> Debug.log (Debug.toString error) (model, Cmd.none)

    GotSetPasswordResult result ->
      case result of
        Ok () -> Debug.log "Ok" (model, Session.getSession model.email model.password |> Cmd.map SessionMsg )
        Err error -> Debug.log (Debug.toString error) (model, Cmd.none)
    
    _ -> ({model | processing = False}, Cmd.none)

view : Model -> Html Msg
view model = 
  case model.userId of
    Just reg -> formView model
    Nothing -> text "Loading..."

formView : Model -> Html Msg
formView model =
  let
    submitButton = 
      if model.processing then
        Button.button
          [ Button.primary, Button.disabled True, Button.attrs [ Spacing.mr3 ] ]
          [ Spinner.spinner
              [ Spinner.small, Spinner.attrs [ Spacing.mr1 ] ] []
          , text "Slanje prijave..."
          ]
      else
        Button.submitButton 
        [ Button.primary
        , Button.disabled (validForm model)
        ]
        [text "Podnesi prijavu"]
  in
  Form.form 
    [ class "mt-3 mx-auto loginForm"
    , onSubmit SubmittedForm
    , disabled model.processing
    ]
    [ h4 [] [text "Podesite lozinku"]
    -- , alert
    , Form.group []
      [ Form.label [for "email" ] [text "Email"]
      , Input.text 
        [ Input.id "email"
        , Input.onInput Email
        , Input.attrs [ required True ]
        ]
      ]
    , Form.group []
      [ Form.label [for "password" ] [text "Lozinka"]
      , Input.password 
        [ Input.id "password"
        , Input.onInput Password
        , Input.attrs [ required True ]
        ]
      ]
    , Form.group [ ]
      [ Form.label [for "confirmPassword" ] [text "Potvrda lozinke"]
      , Input.password 
        [ Input.id "confirmPassword"
        , Input.onInput ConfirmPassword
        , Input.attrs 
          [ required True
          , classList 
              [ ("is-invalid", model.password /= model.confirmPassword)] 
          ]
        ]
      , Form.invalidFeedback [] [ text "Lozinke se ne poklapaju!" ]
      ]
    , submitButton  
    ] 

init =
  Model Nothing "" "" "" False

loadRequest : String -> Cmd Msg
loadRequest uuid = 
  Http.get
    { url = "http://localhost:4000/api/users/" ++ uuid
    , expect = Http.expectJson GotLoadingResult ( field "id" int ) 
    } 

setPassword {email, password, userId} =
  let
    id = 
      Maybe.map String.fromInt userId 
      |> Maybe.withDefault ""
    body =
      Encode.object 
        [ ("user"
          , Encode.object
            [ ("email", Encode.string email)
            , ("password", Encode.string password)
            ]
          )
        ]
  in
  Http.request
    { method = "PATCH"
    , headers = []
    , url = "http://localhost:4000/api/users/" ++ id
    , body = Http.jsonBody body
    , expect = Http.expectWhatever GotSetPasswordResult
    , timeout = Nothing
    , tracker = Nothing
    }

validForm : Model -> Bool
validForm model =
  model.password /= model.confirmPassword

