module Student exposing (..)

import Html exposing (Html, text, div)
import Http
import Json.Decode exposing (field, list)

import Material.CircularProgress as CircularProgress

import Professor.Settings exposing (Msg(..))
import Api
import StudentsActivity exposing (StudentsActivity, ActivityType(..))
import User.Session exposing (StudentInfo)

type StudentActivityFragment
  = Group
  | Topic 
  | CV 

type alias Model =
  { fragments : List StudentActivityFragment
  , loading : Bool
  , studentInfo : StudentInfo
  }

type Msg = 
  LoadedActivities (Result Http.Error (List StudentsActivity))  

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of 
    LoadedActivities activitiesResult ->
      case activitiesResult of
        Ok activities -> ( {model | loading = False, fragments = (List.map mapToFragments activities)  }, Cmd.none)
        _ -> (model, Cmd.none)

init : StudentInfo -> Model 
init info = Model [] True info

view : Model -> Html Msg
view {fragments, loading, studentInfo} = Debug.log (Debug.toString studentInfo) <|
  if loading then
    CircularProgress.indeterminate CircularProgress.config
  else
    div []
    ( List.map viewFragment fragments )

viewFragment : StudentActivityFragment -> Html Msg
viewFragment fragment = 
  case fragment of
    Group -> div [] [text "Group"]
    CV -> div [] [text "CV"]
    Topic -> div [] [text "Topic"]

getActivities : String -> Cmd Msg
getActivities token = 
  Api.get 
    { url = Api.endpoints.activities
    , token = token
    , expect = Http.expectJson LoadedActivities (field "data" (list StudentsActivity.decodeActivity))
    }

mapToFragments : StudentsActivity -> StudentActivityFragment
mapToFragments activity =
  case activity.activityType of
    CreateGroup -> Group
    SelectTopic -> Topic
    _ -> CV

initCmd : Model -> String -> Cmd Msg
initCmd model token = 
  activitiesCmd model token

activitiesCmd : Model -> String -> Cmd Msg
activitiesCmd model token =
  if List.isEmpty model.fragments then 
    getActivities token
  else 
    Cmd.none