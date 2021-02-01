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

import Material.Button as Button  
import Material.IconButton as IconButton
import Material.Icon as Icon
import Material.List as MList
import Material.List.Item as MListItem
import Material.Menu as Menu
import Material.Typography as Typography

import User.Login as Login
import User.SetPassword as SetPassword
import User.Session as Session exposing (Session, silentTokenRefresh, logout)
import Registration
import Professor

import Util exposing (emptyHtmlNode)
import Route exposing (..)
import Page exposing (..)
import Professor
import User.Type exposing (UserType(..), getUserType)
import Route
import Page
import Route exposing (Route(..))
import Fuzz exposing (result)

type ContentModel
  = ProfessorModel Professor.Model
  | StudentModel
  | AdminModel
  | NoContent

type alias Model =
  { currentUser: UserType
  , currentRoute: Route
  , session: Maybe Session.Session 
  , page: Page
  , key: Nav.Key
  , isMenuOpened: Bool
  , mainContent: ContentModel
  , loading: Bool
  }

type Msg
  = ClickedLink Browser.UrlRequest
  | ChangedUrl Url
  | GotProfessorMsg Professor.Msg
  | GotLoginMsg Login.Msg
  | GotRegistrationMsg Registration.Msg
  | GotPasswordMsg SetPassword.Msg
  | GotInitSessionMsg Session.Msg
  | GotSessionMsg Session.Msg
  | RefreshTick Time.Posix
  | MenuOpened
  | MenuClosed
  | Logout

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case ( msg, model.page, model.mainContent) of
    ( ClickedLink urlRequest, _, _ ) ->
      case urlRequest of
        Browser.External href ->
          ( model, Nav.load href )

        Browser.Internal url ->
           ( model, Nav.pushUrl model.key (Url.toString url) )

    ( ChangedUrl url, _, _ ) ->
      updateUrl url model
    
    ( GotInitSessionMsg (Session.GotTokenResult result), _ , _) ->
      let 
        {currentRoute, key} = model
        user = getUserType result
        {route, redirection} = Route.guard user currentRoute key
  
        session = 
          case result of
            Ok sess -> Just sess
            Err _ -> Nothing

        model_ = setContentModel user {model | loading = False, session = session}
        
        cmd = Cmd.batch 
          [ initCommand route model_
          , redirection
          ]
      in
        (model_, cmd)
        
    ( GotSessionMsg (Session.GotTokenResult result), _, _ ) ->
      case result of
        Ok session -> 
          let 
            user = getUserType result
            model_ = setContentModel user {model | session = Just session}
          in
          ( model_ , Cmd.none )
        Err _  -> (model, Cmd.none)
    
    ( GotSessionMsg (Session.GotSessionResult result), _, _ ) -> 
      case (result, model.page) of
        (Ok session, _ ) -> 
          let 
            user = getUserType result
            model_ = setContentModel user {model | session = Just session}
          in
          ( model_ , Route.redirectTo model.key HomeRoute )

        (Err httpError, LoginPage loginModel) -> 
          ( {model | page = LoginPage (Login.updateError loginModel httpError)} , Cmd.none)
        
        _ -> (model, Cmd.none)

    ( GotLoginMsg loginMsg, LoginPage loginModel, _ ) ->
      Login.update loginMsg loginModel
        |> toPageWithModel LoginPage GotSessionMsg model

    ( GotPasswordMsg setPwdMsg, SetPasswordPage setPwdModel, _ ) ->
      case setPwdMsg of
        SetPassword.SessionMsg (Session.GotSessionResult (Ok session)) -> 
         ( { model | session = Just session, currentUser = getUserType (Ok session)}
         , Route.redirectTo model.key HomeRoute )

        _ ->
          SetPassword.update setPwdMsg setPwdModel
            |> toPageWithModel SetPasswordPage GotPasswordMsg model

    ( GotRegistrationMsg regMsg, RegistrationPage regModel, _ ) ->
      Registration.update regMsg regModel
        |> toPageWithModel RegistrationPage GotRegistrationMsg model

    ( GotProfessorMsg profMsg, professorPage, ProfessorModel model_ ) -> 
      let
        (profModel, cmd)  = Professor.update profMsg model_ (tokenFrom model.session)
      in  
      ( {model | mainContent = ProfessorModel profModel}
      , cmd |> Cmd.map GotProfessorMsg )

    ( RefreshTick _, _, _ ) -> 
      (model, silentTokenRefresh |>  Cmd.map GotSessionMsg)

    ( MenuOpened , _ , _) -> 
      ({model | isMenuOpened = True}, Cmd.none)

    ( MenuClosed , _ , _) -> 
      ({model | isMenuOpened = False}, Cmd.none)

    ( Logout, _, _ ) -> 
      ( {model | session = Nothing, currentUser = Guest, isMenuOpened = False}
      , Cmd.batch 
        [ Route.redirectTo model.key HomeRoute
        , logout |> Cmd.map GotSessionMsg
        ]
      )
    _ -> (model, Cmd.none)

toPageWithModel : (pageModel -> Page)-> (subMsg -> Msg) -> Model -> (pageModel, Cmd subMsg) -> ( Model, Cmd Msg )
toPageWithModel page toMsg model (pageModel, pageCmd) =
  ( { model | page = page pageModel }
  , Cmd.map toMsg pageCmd 
  )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ case model.session of
        Just {expiresIn} -> Time.every (1000 * (expiresIn - 5))  RefreshTick
        Nothing -> Sub.none    
    ]

updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model = Debug.log (Url.toString url) <|
  let
    route = Route.fromUrl url
    page = Page.forRoute route

    model_ = {model | page = page, currentRoute = route, isMenuOpened = False}
    cmd = initCommand route model_
 in
  ( model_, cmd )

initCommand : Route -> Model -> Cmd Msg
initCommand route model = 
  let 
    {session, mainContent} = model
    token = tokenFrom session
  in
  case (route, mainContent) of
    (SetPasswordRoute uuid, _) -> SetPassword.loadRequest uuid |> Cmd.map GotPasswordMsg
    (ProfessorRoute  _ , ProfessorModel model_ ) -> Professor.initCmd token model_  |> Cmd.map GotProfessorMsg
    _ -> Cmd.none

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  let
    route = Route.fromUrl url
    sessionCheck = silentTokenRefresh |> Cmd.map GotInitSessionMsg 
  in
  (
    { page = Page.forRoute route 
    , key = key
    , currentRoute = route
    , session = Nothing
    , isMenuOpened = False
    , mainContent = NoContent
    , currentUser = Guest
    , loading = True
    } 
  , sessionCheck
  ) 


view model =
  let
    content = 
      if model.loading then 
        text "laoding..." 
      else 
      case (model.page, model.mainContent) of
        (HomePage, _) -> text "Home"
        (StudentPage, _) -> text "Student"
        
        (AdminPage, _) -> text "Admin"
        
        (ProfessorPage _, ProfessorModel profModel ) ->
          Professor.view profModel |> Html.map GotProfessorMsg

        (LoginPage loginModel, _ ) ->
          Login.view loginModel |> Html.map GotLoginMsg

        (RegistrationPage regModel, _ ) ->
          Registration.view regModel |> Html.map GotRegistrationMsg

        (SetPasswordPage setPwsModel, _ ) ->
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
    { page, currentUser, currentRoute } = model
    
    navIcon: { route : Route, icon : String } -> Html Msg
    navIcon { route, icon } = 
      let
        iconClass = 
          if route == currentRoute then 
            "active" 
          else 
            "unactive" 
      in
      div
        [class "nav-icon"] 
        [ a 
          [href (Route.toString route), class "center"  ] 
          [Icon.icon [class iconClass] icon]
        ] 

    navbar = 
      let
        navItems = nav [] << (::) (navIcon {route = HomeRoute, icon = "home"})
      in
      case currentUser of
        Student -> navItems [ navIcon {route = StudentRoute, icon = "school"} ]
        Professor -> navItems ( List.map (\{icon, route} -> navIcon {icon = icon, route = ProfessorRoute route}) Professor.navIcons)
        _ -> emptyHtmlNode

    profileDropUp = 
      let 
        menuContent = 
          case currentUser of
            Guest ->  
              MList.list
                (MList.config |> MList.setWrapFocus True)
                (MListItem.listItem (MListItem.config |> MListItem.setHref (Just "/login"))
                    [ MListItem.graphic [] [ Icon.icon [] "login" ]
                    , text "Prijava"
                    ]
                )
                [ MListItem.listItem (MListItem.config |> MListItem.setHref (Just "/register"))
                    [ MListItem.graphic [] [ Icon.icon [] "person_add" ]
                    , text "Registracija"
                    ]
                ]
            _ ->
              MList.list
                (MList.config |> MList.setWrapFocus True)
                ( MListItem.listItem (MListItem.config |> MListItem.setOnClick Logout)
                    [ MListItem.graphic [] [ Icon.icon [] "logout" ]
                    , div [style "display" "inline-block", style "width" "100px"]  [text "Odjavi se"]
                    ]
                )
                []
      in
      div [ Menu.surfaceAnchor, class "account-dropup" ]
          [ IconButton.iconButton
            (IconButton.config |> IconButton.setOnClick MenuOpened |> IconButton.setAttributes [class "account-button"] )
            (IconButton.icon "account_circle")
          , Menu.menu
              (Menu.config
                  |> Menu.setOpen model.isMenuOpened
                  |> Menu.setOnClose MenuClosed
                  |> Menu.setAttributes [class "account-menu"]
              )
              [ menuContent ]
          ]
  in
  header [] 
    [ span [id "logo", Typography.headline6] [text "MSNR"]
    , navbar
    , profileDropUp
    ]

tokenFrom : Maybe Session.Session -> String
tokenFrom session =
  Maybe.withDefault "" <| Maybe.map (\s -> s.accessToken) session

setContentModel : UserType -> Model -> Model
setContentModel user model =
  case user of
    Professor -> {model | mainContent = ProfessorModel Professor.init, currentUser = user } 
    Student -> {model | mainContent = StudentModel, currentUser = user } 
    Admin -> {model | mainContent = AdminModel, currentUser = user } 
    Guest -> {model | mainContent = NoContent, currentUser = user } 


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