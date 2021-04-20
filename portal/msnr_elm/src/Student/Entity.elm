module Student.Entity exposing (..)

import Json.Decode as Decode


type alias StudentEntity =
    { studentId : Int
    , firstName : String
    , lastName : String
    , indexNumber : String
    , email : String
    }


decodeStudent : Decode.Decoder StudentEntity
decodeStudent =
    Decode.map5 StudentEntity
        (Decode.field "id" Decode.int)
        (Decode.field "first_name" Decode.string)
        (Decode.field "last_name" Decode.string)
        (Decode.field "index_number" Decode.string)
        (Decode.field "email" Decode.string)
