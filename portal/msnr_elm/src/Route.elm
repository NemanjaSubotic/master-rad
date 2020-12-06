module Route exposing (..)

import Url.Parser as Parser exposing ((</>), Parser, s, string, top, parse)
import Url exposing (Url)

type Route
  = HomeRoute
  | StudentRoute
  | LoginRoute
  | RegistrationRoute
  | ProfessorRoute
  | AdminRoute
  | SetPassword String

parser : Parser (Route -> a) a
parser =
  Parser.oneOf
    [ Parser.map HomeRoute top
    , Parser.map StudentRoute (s "student")
    , Parser.map LoginRoute (s "login")
    , Parser.map RegistrationRoute (s "register")
    , Parser.map ProfessorRoute (s "professor")
    , Parser.map AdminRoute (s "admin")
    , Parser.map SetPassword (s "setPassword" </> string)
    ]

fromUrl : Url -> Maybe Route
fromUrl =
  parse parser 