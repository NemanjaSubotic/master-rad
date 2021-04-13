module User.Session exposing (..)
import Http
import Json.Decode exposing (Decoder, map3, map4, field, string, float, int, nullable)
import Json.Encode as Encode
import Api

type Msg 
    = GotSessionResult (Result Http.Error Session)
    | GotTokenResult (Result Http.Error Session)
    | DeleteSessionResult (Result Http.Error ())

type alias Session = 
    { accessToken : String
    , expiresIn : Float
    , user : User
    , studentInfo : Maybe StudentInfo 
    }
type alias User =
  { email: String
  , name: String
  , role: String
  }

type alias StudentInfo =
  { id : Int
  , groupId : Maybe Int
  , semesterId : Int
  -- , indexNumber : String 
  }
    
decodeSession : Decoder Session
decodeSession = 
  map4 Session
    (field "access_token" string)
    (field "expires_in" float)
    (field "user" decodeUser)
    (field "student_info" (nullable decodeStudentInfo))

decodeUser : Decoder User
decodeUser = 
  map3 User
    (field "email" string)
    (field "name" string)
    (field "role" string)

decodeStudentInfo : Decoder StudentInfo
decodeStudentInfo = 
  map3 StudentInfo
    (field "student_id" int)
    (field "group_id" (nullable int))
    (field "semester_id" int)
    
silentTokenRefresh : Cmd Msg
silentTokenRefresh = 
  Api.getWithCredentials
  { url = Api.endpoints.refreshToken
  , expect = Http.expectJson GotTokenResult decodeSession
  }

getSession : String -> String -> Cmd Msg
getSession email password =
  let
    body =
      Encode.object 
        [ ("email", Encode.string email)
        , ("password", Encode.string  password)
        ]
  in
  Api.postWithCredentials
    { url = Api.endpoints.login
    , body = Http.jsonBody body
    , expect = Http.expectJson GotSessionResult decodeSession
    }

logout : Cmd Msg
logout = 
  Api.getWithCredentials
    { url = Api.endpoints.logout
    , expect = Http.expectWhatever DeleteSessionResult
    }
