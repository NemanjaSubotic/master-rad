module User.Login exposing (Model, Msg, update, view, init, updateError)

import Html exposing (Html, text, form, div, h2)
import Html.Attributes exposing (class)
import Html.Events exposing (onSubmit)
import User.Session as Session exposing (getSession)
import Http

import Material.Button as Button
import Material.Typography as Typography

import Util exposing (..)
-- import Material.Snackbar as Snackbar

type alias Model =
    { email: String
    , password: String
    , error: Maybe Http.Error
    , processing: Bool
    }

type Msg
    = Email String
    | Password String
    | SubmittedForm

update : Msg -> Model -> ( Model, Cmd Session.Msg )
update msg model =
    case msg of
        Email email -> ({model | email = email}, Cmd.none)
        Password password -> ({model | password = password}, Cmd.none)
        SubmittedForm -> ( { model | error = Nothing, processing = True}, getSession model.email model.password)


init : Model
init = Model "" "" Nothing False

view :  Model -> Html Msg
view model = 
  let
    viewInput inputType label msg = 
      formInput 
      { inputType = inputType
      , class_ = "login-input"
      , label = label
      , msg = msg
      } 

    submitBtn = 
      submitButton 
        { text = "Prijavi se"
        , disabled = model.processing
        , icon = Just (Button.icon "login")
        }
  in
  div [class "center"]
    [ form [onSubmit SubmittedForm]
        [ h2 [Typography.headline5, class "heading"] [ text "Prijava korisnika" ]
        , viewInput "email" ( Just "Email" ) Email
        , viewInput "password" ( Just "Lozinka") Password
        , submitBtn
        , progressLine model.processing
        ]
    ]

updateError : Model -> Http.Error -> Model
updateError model httpError =
  {model | error = Just httpError, processing = False}
