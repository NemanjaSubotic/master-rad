module User.SetPassword exposing (..)

import Html exposing (Html, text, h4, form, div)
import Html.Attributes exposing (class, for, disabled, classList, required)
import Html.Events exposing (onSubmit)
import Json.Decode exposing (field, int)
import Json.Encode as Encode
import Http exposing (emptyBody)

import Material.Button as Button
import Material.CircularProgress as CircularProgress

import User.Session as Session
import Util exposing (..)

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
    Email email -> 
      ({model | email = email}, Cmd.none)

    Password password ->
      ({model | password = password}, Cmd.none)

    ConfirmPassword password -> 
      ({model | confirmPassword = password}, Cmd.none)

    SubmittedForm -> 
      ({ model | processing = True }, setPassword model)
    
    GotLoadingResult result -> 
      case result of
        Ok userId ->({model | userId = Just userId}, Cmd.none)
        Err error -> (model, Cmd.none)

    GotSetPasswordResult result ->
      case result of
        Ok () -> (model, Session.getSession model.email model.password |> Cmd.map SessionMsg )
        Err error -> (model, Cmd.none)
    
    _ -> ({model | processing = False}, Cmd.none)

view : Model -> Html Msg
view model = 
  case model.userId of
    Just reg -> 
      formView model
    Nothing -> 
      div [class "center"] 
        [CircularProgress.indeterminate CircularProgress.config]

formView : Model -> Html Msg
formView model =
  let
    notValid = 
      String.isEmpty model.email ||
      String.isEmpty model.password ||
      String.isEmpty model.confirmPassword ||
      model.password /= model.confirmPassword

    viewInput inputType label msg  = 
      formInput 
      { inputType = inputType
      , class_ = "login-input"
      , label = label
      , msg = msg
      } 

    submitBtn = 
      submitButton 
        { text = "Potvrdi"
        , disabled = model.processing || notValid
        , icon = Just (Button.icon "vpn_key")
        }

  in
  div [class "center"]
  [ form 
      [ onSubmit SubmittedForm
      , disabled model.processing
      ]
      [ h4 [] [text "Podesite lozinku"]
      , viewInput "email" ( Just "Email" ) Email 
      , viewInput "password" ( Just "Lozinka") Password 
      , viewInput "password" ( Just "Potvrda lozinke") ConfirmPassword 
      , submitBtn
      ]
  ]

init : Model
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
    id = Maybe.withDefault "" ( Maybe.map String.fromInt userId )
      
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

