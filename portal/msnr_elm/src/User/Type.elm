module User.Type exposing (..)
import User.Session exposing (Session)
import Http exposing (Error)

type UserType
  = Guest
  | Student
  | Professor
  | Admin

getUserType: Result Error Session -> UserType
getUserType result =
  case result of
    Ok {user} ->
      case user.role of
        "student" -> Student
        "admin" -> Admin
        "professor" -> Professor
        _ -> Guest
    Err _ -> Guest