module Route exposing (..)

import Url.Parser as Parser exposing ((</>), Parser, s, string, top, parse)
import Url exposing (Url)
import Professor
import User.Type exposing (UserType(..))
import Browser.Navigation as Nav

type Route
  = HomeRoute
  | StudentRoute
  | LoginRoute
  | RegistrationRoute
  | ProfessorRoute Professor.Route
  | AdminRoute
  | SetPasswordRoute String
  | NotFoundRoute

parser : Parser (Route -> a) a
parser =
  Parser.oneOf
    [ Parser.map HomeRoute top
    , Parser.map StudentRoute (s "student")
    , Parser.map LoginRoute (s "login")
    , Parser.map RegistrationRoute (s "register")
    , Parser.map ProfessorRoute (s "professor" </> Professor.routeParser)
    , Parser.map AdminRoute (s "admin")
    , Parser.map SetPasswordRoute (s "setPassword" </> string)
    , Parser.map NotFoundRoute (s "notFound")
    ]

fromUrl : Url -> Route
fromUrl =
  Maybe.withDefault NotFoundRoute << parse parser

guard : UserType -> Route -> Nav.Key -> { route: Route, redirection: Cmd msg}
guard user route key  = 
  let
    redirectWithKey = redirectTo key
  in
  case (user, route) of
    (Guest, HomeRoute ) -> { route = HomeRoute, redirection = Cmd.none}
    (Guest, LoginRoute ) -> { route = LoginRoute, redirection = Cmd.none}
    (Guest, RegistrationRoute) -> { route = RegistrationRoute, redirection = Cmd.none}
    (Guest, SetPasswordRoute uuid ) -> { route = SetPasswordRoute uuid, redirection = Cmd.none} 
    (Student _, StudentRoute) -> { route = StudentRoute, redirection = Cmd.none}
    (Student _, _ ) ->  { route = HomeRoute, redirection = redirectWithKey HomeRoute }
    (Professor, ProfessorRoute subRoute) -> { route = ProfessorRoute subRoute, redirection = Cmd.none}
    (Professor, _ ) ->  { route = HomeRoute, redirection = redirectWithKey HomeRoute} 
    (Admin, AdminRoute) -> { route = AdminRoute, redirection = Cmd.none}
    (Admin, _ ) ->  { route = HomeRoute, redirection = redirectWithKey HomeRoute }
    _ ->{ route = NotFoundRoute, redirection = redirectWithKey NotFoundRoute }


toString : Route -> String
toString route =
  case route of
    HomeRoute -> "/"
    StudentRoute -> "/student"
    LoginRoute -> "/login"
    RegistrationRoute -> "/register"
    ProfessorRoute subRoute -> "/professor" ++ Professor.routeToString subRoute
    AdminRoute -> "/adim"
    SetPasswordRoute uuid -> "/setPassword/" ++ uuid
    NotFoundRoute -> "/notFound"


redirectTo : Nav.Key -> Route -> Cmd msg
redirectTo key route  =
  Nav.pushUrl key ( toString route )  