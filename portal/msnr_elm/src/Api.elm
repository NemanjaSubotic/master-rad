module Api exposing (endpoints, get, getWithCredentials, post, postWithCredentials, put)

import Html.Attributes exposing (headers)
import Http exposing (Body, Expect, Header)


baseUrl : String
baseUrl =
    "http://localhost:4000/api/"


type alias Endpoints =
    { activities : String
    , studentsRegistrations : String
    , refreshToken : String
    , login : String
    , logout : String
    , groups : String
    , students : String
    }


endpoints : Endpoints
endpoints =
    { activities = baseUrl ++ "activities"
    , studentsRegistrations = baseUrl ++ "registrations"
    , refreshToken = baseUrl ++ "auth/refresh"
    , login = baseUrl ++ "auth/login"
    , logout = baseUrl ++ "auth/logout"
    , groups = baseUrl ++ "groups"
    , students = baseUrl ++ "students"
    }


authHeader : String -> Header
authHeader token =
    Http.header "Authorization" ("Bearer " ++ token)


get :
    { url : String
    , token : String
    , expect : Http.Expect msg
    }
    -> Cmd msg
get { url, token, expect } =
    Http.request (requestParams "GET" [ authHeader token ] url Http.emptyBody expect)


post :
    { url : String
    , body : Http.Body
    , token : String
    , expect : Http.Expect msg
    }
    -> Cmd msg
post { url, body, token, expect } =
    Http.request (requestParams "POST" [ authHeader token ] url body expect)


put :
    { url : String
    , body : Http.Body
    , token : String
    , expect : Http.Expect msg
    }
    -> Cmd msg
put { url, body, token, expect } =
    Http.request (requestParams "PUT" [ authHeader token ] url body expect)


requestParams :
    String
    -> List Header
    -> String
    -> Body
    -> Expect msg
    ->
        { method : String
        , headers : List Header
        , url : String
        , body : Body
        , expect : Expect msg
        , timeout : Maybe Float
        , tracker : Maybe String
        }
requestParams method headers url body expect =
    { method = method
    , headers = headers
    , url = url
    , body = body
    , expect = expect
    , timeout = Nothing
    , tracker = Nothing
    }



-- getWithCredentials


getWithCredentials :
    { url : String
    , expect : Http.Expect msg
    }
    -> Cmd msg
getWithCredentials { url, expect } =
    Http.riskyRequest (requestParams "GET" [] url Http.emptyBody expect)


postWithCredentials :
    { url : String
    , body : Http.Body
    , expect : Http.Expect msg
    }
    -> Cmd msg
postWithCredentials { url, body, expect } =
    Http.riskyRequest (requestParams "POST" [] url body expect)
