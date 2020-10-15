module User.Session exposing (..)
import Http
import Json.Decode exposing (Decoder, map2, map3, field, string, list)

type Msg 
    = GotLoginResult (Result Http.Error Session)
    | GotTokenResult (Result Http.Error Session)

type alias Session = 
    { accessToken: String
    , user: User 
    }
type alias User =
    { email: String
    , name: String
    , roles: List String
    }

decodeSession : Decoder Session
decodeSession = 
    map2 Session
    (field "access_token" string)
    (field "user" decodeUser)

decodeUser : Decoder User
decodeUser = 
    map3 User
    (field "email" string)
    (field "name" string)
    (field "roles" (list string))
