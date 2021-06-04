module Page exposing (..)

import Professor
import Registration
import Route exposing (..)
import User.Login as Login
import User.SetPassword as SetPassword
import User.Type exposing (UserType(..))


type Page
    = HomePage
    | LoginPage Login.Model
    | RegistrationPage Registration.Model
    | SetPasswordPage SetPassword.Model
    | ProfessorPage Professor.Page
    | StudentPage
    | AdminPage
    | NotFoundPage


forRoute : Route -> Page
forRoute route =
    case route of
        HomeRoute ->
            HomePage

        LoginRoute ->
            LoginPage Login.init

        RegistrationRoute ->
            RegistrationPage Registration.init

        SetPasswordRoute _ ->
            SetPasswordPage SetPassword.init

        ProfessorRoute profRoute ->
            ProfessorPage (Professor.pageFromRoute profRoute)

        StudentRoute ->
            StudentPage

        AdminRoute ->
            AdminPage

        _ ->
            NotFoundPage
