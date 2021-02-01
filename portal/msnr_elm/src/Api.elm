module Api exposing (..)

import Http

authHeader : String -> Http.Header
authHeader token = 
  Http.header "Authorization" ("Bearer " ++ token)

