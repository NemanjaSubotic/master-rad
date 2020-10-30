module Main exposing (main, Msg)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)
import Http
import Time
import Json.Encode
import Json.Decode
import User.Session as Session
import User.Login as Login 
import User.Session exposing (Session, silentTokenRefresh)
import Bootstrap.Button as Button
import Bootstrap.Dropdown as Dropdown
import Util exposing (emptyHtmlNode)
import Icons exposing (..)
import Expect exposing (false)

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
  , profileDropdownState : Dropdown.State
  }

type Msg
  = ClickedLink Browser.UrlRequest
  | ChangedUrl Url
  | GotLoginMsg Login.Msg
  | GotSessionMsg Session.Msg
  | RefreshTick Time.Posix
  | ProfileDropdownMsg Dropdown.State 

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
        Ok session -> ({model | session = Just session}, Cmd.none)
        Err httpError  -> (model, Cmd.none)
    
    GotSessionMsg (Session.GotSessionResult result) ->   
      case result of
        Ok session -> ({model | session = Just session}, Nav.pushUrl model.key "/")
        Err httpError -> toLogin model ( )

    GotLoginMsg loginMsg ->
      case model.page of
        LoginPage loginModel ->\
          toLogin model (Login.update loginMsg loginModel)
        _ -> (model, Cmd.none)

    RefreshTick _ -> (model, silentTokenRefresh |>  Cmd.map GotSessionMsg)

    ProfileDropdownMsg state -> ({model | profileDropdownState = state}, Cmd.none)
    

toLogin : Model -> ( Login.Model, Cmd Session.Msg ) -> ( Model, Cmd Msg )
toLogin model (loginModel, cmd) = 
  ( {model | page = LoginPage loginModel}
  , Cmd.map GotSessionMsg cmd
  )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dropdown.subscriptions model.profileDropdownState ProfileDropdownMsg
    , case model.session of
        Just {expiresIn} -> Time.every (1000 * (expiresIn - 5))  RefreshTick
        Nothing -> Sub.none    
    ]
   

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
    
init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  updateUrl 
    url 
    { page = HomePage 
    , key = key
    , session = Nothing
    , profileDropdownState = Dropdown.initialState
    } 
    (silentTokenRefresh |>  Cmd.map GotSessionMsg) 


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
    [ viewHeader model
    , main_ [] [content]
    ]
  }
viewHeader: Model -> Html Msg
viewHeader model =
  let
    { page, session } = model
    
    navIcon name link targetPage = 
      let
        active = targetPage == page      
      in
      div 
        [class "nav-icon"] 
        [ a 
          [href link, classList [ ( "active", active ) ] ] 
          [getNavIcon name active]
        ] 

    mapRolesToPage role =
      case role of
        "student" -> StudentPage
        "profesor" -> ProfesorPage
        "admin" -> AdminPage
        _ -> NotFound

    navItems roles = 
      nav []
       (navIcon "home" "/" HomePage :: List.map (\r -> navIcon r ("/" ++ r) (mapRolesToPage r)) roles)
        
    navbar = 
      case session of
        Nothing -> emptyHtmlNode
        Just {user} -> navItems user.roles
    
    profileDropUp = 
      Dropdown.dropdown
        model.profileDropdownState
        { options = [ Dropdown.dropUp ]
        , toggleMsg = ProfileDropdownMsg
        , toggleButton =
            Dropdown.toggle [] [ profileIcon ]
        , items =
            case session of
              Nothing -> [ Dropdown.anchorItem [ href "/login"] [ text "Prijavi se" ] ]
              Just _ ->
                [ Dropdown.anchorItem [ href "#"] [ text "Promeni lozinku" ]
                , Dropdown.buttonItem [] [ text "Odjavi se" ]
                ]
        }
  in
  header [] 
    [ h5 [id "logo"] [text "MSNR"]
    , navbar
    , profileDropUp
    ]
  
main : Program () Model Msg
main =
  Browser.application
    { init = init
    , onUrlRequest = ClickedLink
    , onUrlChange = ChangedUrl
    , subscriptions = subscriptions
    , update = update
    , view = view
    }