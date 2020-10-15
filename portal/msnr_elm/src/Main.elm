module Main exposing (main, Msg)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)
import Http
import Json.Encode
import Json.Decode
import User.Session as Session
import User.Login as Login 
import User.Session exposing (Session)

type Page
    = HomePage
    | LoginPage Login.Model
    | RegistrationPage
    | EnterPasswordPage
    | ProfesorPage
    | StudentPage
    | AdminPage
    | NotFound

type Route
    = HomeRoute
    | StudentRoute
    | LoginRoute


type alias Model =
    { session: Maybe Session.Session 
    , page: Page
    , key: Nav.Key
    }

 
view : Model -> Document Msg
view model =
    let
        content = 
            case model.page of
                HomePage -> text "Home"
                StudentPage -> text "Student"
                ProfesorPage -> text "Profesor"
                AdminPage -> text "Admin"
                LoginPage loginModel ->
                    Login.view loginModel
                        |> Html.map GotLoginMsg
                _ -> text "Not Found"
    in
    { title = "MSNR"
    , body = 
        [ viewHeader model.page model.session
        , content
        ]
    }
viewHeader: Page -> Maybe Session.Session -> Html Msg
viewHeader page session =
    let
        logo =
            a [class "navbar-brand", href "/"] [ text "MSNR" ]
        
        loginsButtons =  
             div []
                 (
                     case page of 
                        LoginPage _ -> [] 
                        _  ->
                            [ a [class "btn  btn-outline-primary", href "/login"] [text "Prijava"]
                            , button [class "btn btn-primary"] [text "Registracija"]
                            ]
                 )

        profileButton =  button [class "btn btn-outline-primary"] [text "Profil"] 

        links = 
            ul [ class "list-group list-group-horizontal"]
                [ navLink HomePage { url = "/", caption = "Home" }
                , navLink StudentPage { url = "/student", caption = "Student" }
                ]   

        navLink : Page -> { url : String, caption : String } -> Html msg
        navLink targetPage { url, caption } =
            li [ class "list-group-item", classList [ ( "active-link", page == targetPage ) ] ]
                [ a [ href url ] [ text caption ] ]

        navContent = 
            case session of
               Maybe.Nothing -> [ logo, loginsButtons]
               _ -> [ logo, links, profileButton]

    in
    nav [class "navbar navbar-light bg-light justify-content-between"] navContent


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotLoginMsg Login.Msg
    | GotSessionMsg Session.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ChangedUrl url ->
            updateUrl url model Cmd.none
                
        GotSessionMsg (Session.GotTokenResult result) ->    
            case result of
                Ok session -> Debug.log (Debug.toString session) ({model | session = Just session}, Cmd.none)
                Err httpError  -> Debug.log (Debug.toString httpError) (model, Cmd.none)
        
        
        GotSessionMsg (Session.GotLoginResult result) ->    
            case result of
                Ok session -> Debug.log (Debug.toString session) ({model | session = Just session}, Cmd.none)
                Err httpError  -> Debug.log (Debug.toString httpError) (model, Cmd.none)

        GotLoginMsg loginMsg ->
            case model.page of
                LoginPage loginModel ->
                    toLogin model (Login.update loginMsg loginModel)
                _ -> (model, Cmd.none)
        

toLogin : Model -> ( Login.Model, Cmd Session.Msg ) -> ( Model, Cmd Msg )
toLogin model (loginModel, cmd) = 
    ( {model | page = LoginPage loginModel}
    , Cmd.map GotSessionMsg cmd
    )
-- subscriptions : Model -> Sub Msg
-- subscriptions _ =
--     Sub.none

updateUrl : Url -> Model -> Cmd Msg -> ( Model, Cmd Msg )
updateUrl url model cmd =
    case Parser.parse parser url of
        Just HomeRoute ->
            ( {model | page = HomePage}, cmd)

        Just StudentRoute ->
            ( {model | page = StudentPage}, cmd)

        Just LoginRoute ->
            ( {model | page = LoginPage Login.initialModel}, cmd)

        Nothing ->
            ( { model | page = NotFound }, cmd )


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map HomeRoute Parser.top
        , Parser.map StudentRoute (Parser.s "student")
        , Parser.map LoginRoute (Parser.s "login")
        ]


-- loginBody = 
--     Json.Encode.object 
--         [ ("email", Json.Encode.string "test@student")
--         , ("password", Json.Encode.string  "test")
--         ]
 

-- accessTokenDecoder = Json.Decode.field "access_token" Json.Decode.string 

authCall = 
    Http.riskyRequest
        { method = "GET"
        , headers = [ Http.header "Sec-Fetch-Site" "none"]
        , url = "http://localhost:4000/api/auth/refresh"
        , body = Http.emptyBody
        , expect = Http.expectJson Session.GotTokenResult Session.decodeSession
        , timeout = Nothing
        , tracker = Nothing
        }
        
init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    updateUrl url { page = HomePage , key = key, session = Nothing } (authCall |>  Cmd.map GotSessionMsg) 

main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }