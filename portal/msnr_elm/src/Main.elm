module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)
import Http
import Time

import Bootstrap.Button as Button
import Bootstrap.Dropdown as Dropdown

import User.Login as Login
import User.Session as Session exposing (Session, silentTokenRefresh, logout)
import Registration
import Professor
import SetPassword
import Util exposing (emptyHtmlNode)
import Icons exposing (..)
import SetPassword
import Route exposing (..)
import Page exposing (..)
import Page exposing (Page(..))

type alias Model =
  { session: Maybe Session.Session 
  , page: Page
  , key: Nav.Key
  , profileDropdownState : Dropdown.State
  }

type Msg
  = ClickedLink Browser.UrlRequest
  | ChangedUrl Url
  | GotProfessorMsg Professor.Msg
  | GotLoginMsg Login.Msg
  | GotRegistrationMsg Registration.Msg
  | GotPasswordMsg SetPassword.Msg
  | GotSessionMsg Session.Msg
  | RefreshTick Time.Posix
  | ProfileDropdownMsg Dropdown.State
  | Logout

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case ( msg, model.page) of
    ( ClickedLink urlRequest, _ ) ->
      case urlRequest of
        Browser.External href ->
          ( model, Nav.load href )

        Browser.Internal url ->
           ( model, Nav.pushUrl model.key (Url.toString url) )

    ( ChangedUrl url, _ ) ->
      updateUrl url model Cmd.none
        
    ( GotSessionMsg (Session.GotTokenResult result), _ ) ->   
      case result of
        Ok session -> ({model | session = Just session}, Cmd.none)
        Err httpError  -> (model, Cmd.none)
    
    ( GotSessionMsg (Session.GotSessionResult result), _ ) ->   
      case (result, model.page) of
        (Ok session, _ ) -> 
          ({model | session = Just session}, Nav.pushUrl model.key "/")

        (Err httpError, LoginPage loginModel) -> 
          ( {model | page = LoginPage (Login.updateError loginModel httpError)} , Cmd.none)
        
        _ -> (model, Cmd.none)
    
    
    ( GotLoginMsg loginMsg, LoginPage loginModel ) ->
      Login.update loginMsg loginModel
        |> toPage LoginPage GotSessionMsg model

    ( GotPasswordMsg setPwdMsg, SetPasswordPage setPwdModel ) ->
      case setPwdMsg of
        SetPassword.SessionMsg (Session.GotSessionResult (Ok session)) -> 
         ({model | session = Just session}, Nav.pushUrl model.key "/")

        _ ->
          SetPassword.update setPwdMsg setPwdModel
            |> toPage SetPasswordPage GotPasswordMsg model

    ( GotRegistrationMsg regMsg, RegistrationPage regModel ) ->
      Registration.update regMsg regModel
        |> toPage RegistrationPage GotRegistrationMsg model

    ( GotProfessorMsg profMsg, ProfessorPage profModel ) ->
      Professor.update profMsg profModel
        |> toPage ProfessorPage GotProfessorMsg model 

    ( RefreshTick _, _ ) -> 
      (model, silentTokenRefresh |>  Cmd.map GotSessionMsg)

    ( ProfileDropdownMsg state, _) -> 
      ({model | profileDropdownState = state}, Cmd.none)

    ( Logout, _ ) -> 
      ( {model | session = Nothing}
      , Cmd.batch 
        [ Nav.pushUrl model.key "/"
        , logout |> Cmd.map GotSessionMsg
        ]
      )
    
    -- ( GotSessionMsg (Session.DeleteSessionResult _), _ )  -> (model, Cmd.none)
    _ -> (model, Cmd.none)

toPage : (pageModel -> Page)-> (subMsg -> Msg) -> Model -> (pageModel, Cmd subMsg) -> ( Model, Cmd Msg )
toPage page toMsg model (pageModel, pageCmd) =
  ( { model | page = page pageModel }
  , Cmd.map toMsg pageCmd 
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
  case Route.fromUrl url of
    Just HomeRoute ->
      ( {model | page = HomePage}, cmd)

    Just StudentRoute ->
      ( {model | page = StudentPage}, cmd)

    Just LoginRoute ->
      ( {model | page = LoginPage Login.init}, cmd)

    Just RegistrationRoute ->
      ( { model | page = RegistrationPage Registration.init}, cmd)

    Just ProfessorRoute ->
      ( { model | page = ProfessorPage Professor.init}, Professor.loadRequests |> Cmd.map GotProfessorMsg)

    Just (SetPassword uuid) ->
      ( { model | page = SetPasswordPage SetPassword.init}, SetPassword.loadRequest uuid |> Cmd.map GotPasswordMsg)

    Just AdminRoute ->
      ( {model | page = AdminPage}, cmd)

    Nothing ->
      ( { model | page = NotFound }, cmd )

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
        
        AdminPage -> text "Admin"
        
        ProfessorPage profModel ->
          Professor.view profModel |> Html.map GotProfessorMsg

        LoginPage loginModel ->
          Login.view loginModel |> Html.map GotLoginMsg

        RegistrationPage regModel ->
          Registration.view regModel |> Html.map GotRegistrationMsg

        SetPasswordPage setPwsModel ->
          SetPassword.view setPwsModel |> Html.map GotPasswordMsg
        
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
    
    navIcon: { route: Route,  url : String, name : String } -> Html Msg
    navIcon {route, url, name } = 
      let
        active =  isActive { link = route, page = page }
      in
      div
        [class "nav-icon"] 
        [ a 
          [href url, classList [ ( "active", active ) ] ] 
          [getNavIcon name active]
        ] 

    userIcon role = 
      case role of
        "student" -> {route = StudentRoute, url = "/student", name = "student"}
        "admin" -> {route = AdminRoute, url = "/admin", name = "admin"}
        "professor" -> {route = ProfessorRoute, url = "/professor", name = "professor"}
        _ -> {route = HomeRoute, url = "/", name = "home"}
        
    navItems role = Debug.log role
      nav []
       [ navIcon {route = HomeRoute, url = "/", name = "home"}
       , navIcon (userIcon role)
       ]
        
    navbar = 
      case session of
        Nothing -> emptyHtmlNode
        Just {user} -> navItems user.role
    
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
                , Dropdown.buttonItem [ onClick Logout] [ text "Odjavi se" ]
                ]
        }
  in
  header [] 
    [ h5 [id "logo"] [text "MSNR"]
    , navbar
    , profileDropUp
    ]

isActive: {link: Route, page: Page} -> Bool
isActive { link, page } =
  case (link, page) of
    (HomeRoute, HomePage) -> True
    (StudentRoute, StudentPage ) -> True
    (ProfessorRoute, ProfessorPage _) -> True
    (AdminRoute, AdminPage) -> True
    _ -> False

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