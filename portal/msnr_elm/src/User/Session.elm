module User.Session exposing (..)
import Http
import Json.Decode exposing (Decoder, map3, field, string, float)
import Json.Encode

type Msg 
    = GotSessionResult (Result Http.Error Session)
    | GotTokenResult (Result Http.Error Session)
    | DeleteSessionResult (Result Http.Error ())

type alias Session = 
    { accessToken: String
    , expiresIn: Float
    , user: User 
    }
type alias User =
    { email: String
    , name: String
    , role: String
    }

decodeSession : Decoder Session
decodeSession = 
    map3 Session
    (field "access_token" string)
    (field "expires_in" float)
    (field "user" decodeUser)

decodeUser : Decoder User
decodeUser = 
    map3 User
    (field "email" string)
    (field "name" string)
    (field "role" string)

silentTokenRefresh : Cmd Msg
silentTokenRefresh = 
    Http.riskyRequest
        { method = "GET"
        , headers = []
        , url = "http://localhost:4000/api/auth/refresh"
        , body = Http.emptyBody
        , expect = Http.expectJson GotTokenResult decodeSession
        , timeout = Nothing
        , tracker = Nothing
        }

getSession : String -> String -> Cmd Msg
getSession email password =
    let
      body =
        Json.Encode.object 
          [ ("email", Json.Encode.string email)
          , ("password", Json.Encode.string  password)
          ]
    in
    Http.riskyRequest
        { method = "POST"
        , headers = []
        , url = "http://localhost:4000/api/auth/login"
        , body = Http.jsonBody body
        , expect = Http.expectJson GotSessionResult decodeSession
        , timeout = Nothing
        , tracker = Nothing 
        }


logout : Cmd Msg
logout = 
  Http.riskyRequest
        { method = "GET"
        , headers = []
        , url = "http://localhost:4000/api/auth/logout"
        , body = Http.emptyBody
        , expect = Http.expectWhatever DeleteSessionResult
        , timeout = Nothing
        , tracker = Nothing
        }