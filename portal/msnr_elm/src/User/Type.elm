module User.Type exposing (..)
import User.Session exposing (Session, StudentInfo)
import Http exposing (Error)

type UserType
  = Guest
  | Student StudentInfo
  | Professor
  | Admin

getUserType: Result Error Session -> UserType
getUserType result =
  case result of
    Ok {user, studentInfo} ->
      case (user.role, studentInfo) of
        ("student", Just info) -> Student info
        ("admin", _) -> Admin
        ("professor", _) -> Professor
        _ -> Guest
    Err _ -> Guest