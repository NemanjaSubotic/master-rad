module Page exposing (..)

import User.Login as Login
import Registration
import SetPassword
import Professor

type Page
  = HomePage
  | LoginPage Login.Model
  | RegistrationPage Registration.Model
  | SetPasswordPage SetPassword.Model
  | ProfessorPage Professor.Model
  | StudentPage
  | AdminPage
  | NotFound
