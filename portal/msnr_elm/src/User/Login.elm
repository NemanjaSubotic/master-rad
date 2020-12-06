module User.Login exposing (Model, Msg, update, view, init, updateError)

import Html exposing (Html, text)
import Html.Attributes exposing (class, for, disabled, type_)
import Html.Events exposing (onSubmit)
import User.Session as S
import Util exposing (emptyHtmlNode)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Bootstrap.Alert as Alert
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import Http

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

update : Msg -> Model -> ( Model, Cmd S.Msg )
update msg model =
    case msg of
        Email email -> ({model | email = email}, Cmd.none)
        Password password -> ({model | password = password}, Cmd.none)
        SubmittedForm -> ( { model | error = Nothing, processing = True}, S.getSession model.email model.password)

view : Model -> Html Msg
view model = 
    let
      errorAlert = 
        case model.error of
            Just httpError ->
              let
                message =
                  case httpError of
                    Http.BadStatus 401 -> "Pogrešan email ili lozinka!"
                    _ -> "Došlo je do neočekivane greške 😞"
              in
              Alert.simpleDanger [] [text message]
            Nothing -> emptyHtmlNode
      loginButton = 
        if model.processing then
          Button.button
            [ Button.primary, Button.disabled True, Button.attrs [ Spacing.mr3 ] ]
            [ Spinner.spinner
                [ Spinner.small, Spinner.attrs [ Spacing.mr1 ] ] []
            , text "Prijavljivanje..."
            ]
        else
          Button.submitButton [ Button.primary] [text "Prijavi se"]
    in
    Form.form 
      [ class "mt-3 mx-auto loginForm"
      , onSubmit SubmittedForm
      , disabled model.processing
      ]
      [ Form.group []
        [ Form.label [for "email" ] [text "Email"]
        , Input.email 
          [ Input.id "email"
          , Input.onInput Email
          ]
        ]
      , Form.group []
        [ Form.label [for "password" ] [text "Lozinka"]
        , Input.password 
          [ Input.id "password"
          , Input.onInput Password
          ]
        ]
      , errorAlert
      , loginButton  
      ] 

init = Model "" "" Nothing False

updateError : Model -> Http.Error -> Model
updateError model httpError =
  {model | error = Just httpError, processing = False}
