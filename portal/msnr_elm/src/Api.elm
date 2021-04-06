module Api exposing (..)

import Http
import Html.Attributes exposing (headers)
import Url exposing (Url)

baseUrl : String
baseUrl = "http://localhost:4000/api/"

activitiesUrl : String
activitiesUrl = baseUrl ++ "activities"

authHeader : String -> Http.Header
authHeader token = 
  Http.header "Authorization" ("Bearer " ++ token)

get
  : { url : String
    , token : String
    , expect : Http.Expect msg
    } 
  -> Cmd msg
get {url, token, expect} =
  let
     headers = [authHeader token]
  in
  Http.request
    { method = "GET"
      , headers = headers
      , url = url
      , body = Http.emptyBody
      , expect = expect
      , timeout = Nothing
      , tracker = Nothing
    }

put
  : { url : String
    , body : Http.Body
    , token : String
    , expect : Http.Expect msg
    } 
  -> Cmd msg
put {url, body, token, expect} =
  let
    headers = [authHeader token]
  in
  Http.request
    { method = "PUT"
    , headers = headers
    , url = url
    , body = body
    , expect = expect
    , timeout = Nothing
    , tracker = Nothing
    }