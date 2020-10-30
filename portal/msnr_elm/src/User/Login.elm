module User.Login exposing (Model, Msg , update, view, initialModel)

import Util exposing (viewInput)
import Html exposing (Html, div, form, button, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onSubmit)
import Http
import Json.Encode
import User.Session as S

import Task
import User.Session exposing (Session)

type alias Model =
    { email : String
    , password : String
    }

type Msg
    = Email String
    | Password String
    | LoginError Http.Error
    | SubmittedForm

update : Msg -> Model -> ( Model, Cmd S.Msg )
update msg model =
    case msg of
        Email email -> ({model | email = email}, Cmd.none)
        Password password -> ({model | password = password}, Cmd.none)
        SubmittedForm -> (model, S.getSession model.email model.password)
        LoginError err -> Debug.log (Debug.toString err) (model, Cmd.none)

view : Model -> Html Msg
view model = 
    form [class "mt-3 mx-auto loginForm", onSubmit SubmittedForm] 
    [ div [class "form-group"]
        [ viewInput "email" "form-control" "Email" model.email Email]
    , div [class "form-group"]
        [ viewInput "password" "form-control" "Lozinka" model.password Password]
    , button [type_ "submit", class "btn btn-primary"] [text "Prijavi se"]
    ]
  
initialModel : Model
initialModel = Model "" ""
