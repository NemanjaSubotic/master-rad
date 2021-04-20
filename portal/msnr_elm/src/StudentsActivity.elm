
module StudentsActivity exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode

type alias StudentsActivity = 
  { id : Int
  , activityType : ActivityType
  , starts : Int
  , ends : Int
  , points : Int
  , name : String
  , description : String
  }


-- type ActivityType 
--   = IndividualActivity IndividualActivityType
--   | GroupActivity GroupActivityType
--   | Unknown

-- type IndividualActivityType 
--   = CV
--   | Review

-- type GroupActivityType 
--   = CreateGroup
--   | SelectTopic
--   | V1
--   | FinalV


type ActivityType 
  = CV
  | CreateGroup
  | SelectTopic
  | Unknown


decodeActivity : Decode.Decoder StudentsActivity
decodeActivity = 
  Decode.map7 StudentsActivity
  ( Decode.field "id" Decode.int)
  ( Decode.field "type" activityTypeDecoder)
  ( Decode.field "starts_sec" Decode.int)
  ( Decode.field "ends_sec" Decode.int)
  ( Decode.field "points" Decode.int)
  ( Decode.field "name" Decode.string)
  ( Decode.field "description" Decode.string)


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

-- activityTypeDecoder : Decode.Decoder ActivityType
-- activityTypeDecoder =
--   Decode.string |>
--     Decode.andThen 
--       (\val -> 
--         case val of 
--           "group" -> Decode.succeed (GroupActivity CreateGroup)
--           "topic" -> Decode.succeed (GroupActivity SelectTopic)
--           "cv" -> Decode.succeed (IndividualActivity CV)
--           _ -> Decode.succeed Unknown
--       )

activityTypeDecoder : Decode.Decoder ActivityType
activityTypeDecoder =
  Decode.string |>
    Decode.andThen 
      (\val -> 
        case val of 
          "create_group" -> Decode.succeed CreateGroup
          "select_topic" -> Decode.succeed SelectTopic
          "cv" -> Decode.succeed CV
          _ -> Decode.succeed Unknown
      )
