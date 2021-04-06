
module StudentsActivity exposing (..)

import Json.Decode as Decode exposing (field)
import Json.Encode as Encode

type alias StudentsActivity = 
  { id : Int
  , activityType : String
  , starts : Int
  , ends : Int
  , points : Int
  , name : String
  , description : String
  , isGroup: Bool
  }


decodeActivity : Decode.Decoder StudentsActivity
decodeActivity = 
  Decode.map8 StudentsActivity
  ( field "id" Decode.int)
  ( field "type" Decode.string)
  ( field "starts_sec" Decode.int)
  ( field "ends_sec" Decode.int)
  ( field "points" Decode.int)
  ( field "name" Decode.string)
  ( field "description" Decode.string)
  ( field "is_group" Decode.bool)


encodeActivity : StudentsActivity -> Encode.Value
encodeActivity activity = 
  Encode.object
    [ ("activity"
      , Encode.object 
          [ ("starts_sec", Encode.int activity.starts)
          , ("ends_sec", Encode.int activity.ends)
          ]
      ) 
    ] 