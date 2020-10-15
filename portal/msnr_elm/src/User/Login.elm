module User.Login exposing (Model, Msg, update, view, initialModel)

import Util exposing (viewInput)
import Html exposing (Html, div, form, button, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onSubmit)
import Http
import Json.Encode
import User.Session as Session

type alias Model =
    { email : String
    , password : String
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
        SubmittedForm -> (model, loginPost model)

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

createBody: Model -> Json.Encode.Value
createBody model =
    Json.Encode.object 
        [ ("email", Json.Encode.string model.email)
        , ("password", Json.Encode.string  model.password)
        ]
loginPost: Model -> Cmd Session.Msg
loginPost model = 
    Http.riskyRequest
        { method = "POST"
        , headers = []
        , url = "http://localhost:4000/api/auth/login"
        , body = Http.jsonBody (createBody model)
        , expect = Http.expectJson Session.GotLoginResult Session.decodeSession
        , timeout = Nothing
        , tracker = Nothing
        }
    -- Http.post
    --     { url = "http://localhost:4000/api/auth/login"
    --     , body = Http.jsonBody (createBody model)
    --     , expect = Http.expectJson Session.GotLoginResult Session.decodeSession
    --     }

