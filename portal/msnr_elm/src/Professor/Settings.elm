module Professor.Settings exposing (..)

import StudentsActivity exposing (StudentsActivity)
import Html exposing (Html, text, div, h4, form)
import Time exposing (Zone, Month(..))
import Task
import Calendar
import Maybe
import Material.DataTable as DataTable
import Material.IconButton as IconButton
import Material.Button as Button
import Material.Dialog as Dialog
import Material.Typography as Typography

import Array exposing (Array)
import Util exposing (formInput, submitButton, progressLine)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onSubmit)
import Http
import Api
import Json.Decode exposing (array, field)
import Util exposing (ViewMode(..))

type alias Model =
    { zone : Zone
    , activities : Array StudentsActivity
    , dialogOpened : Bool
    , selectedActivity: Maybe SelectedActivity
    , formStarts : String
    , formEnds : String
    , formProcessing: Bool
    }

type alias SelectedActivity =
  { arrayIndex : Int
  , activity : StudentsActivity
  }

init : Model
init = 
  Model Time.utc (Array.fromList []) False Nothing  "" "" False 

type Msg
  = AdjustTimeZone Time.Zone
  | EditTask Int
  | SaveTask
  | Closed
  | Starts String
  | Ends String
  | LoadedActivities (Result Http.Error (Array StudentsActivity)) 

initCmd : Model -> String -> Cmd Msg
initCmd model token = 
  Cmd.batch 
    [ Task.perform AdjustTimeZone Time.here
    , activitiesCmd model token
    ]

update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token = 
  case msg of
    AdjustTimeZone zone -> ({model | zone = zone}, Cmd.none)
    Closed -> ({model | dialogOpened = False}, Cmd.none)
    EditTask index -> 
      let
        dateEdit = dateView Edit model.zone 
      in
      case Array.get index model.activities of
         Nothing -> (model, Cmd.none)
         Just activity -> 
          ( { model | dialogOpened = True
            , selectedActivity = Just { arrayIndex = index, activity = activity }
            , formStarts = dateEdit ( activity.starts * 1000 ) 
            , formEnds = dateEdit ( activity.ends * 1000 )
            , formProcessing = False 
            } 
          , Cmd.none
          ) 
  
    Starts value -> ({model | formStarts = value }, Cmd.none)
    Ends value -> ({model | formEnds = value }, Cmd.none)
      
    SaveTask  -> 
      let
        millisToSec millis = millis // 1000
        mapToSecs = Maybe.map ( millisToSec  << Calendar.toMillis )
        maybeStarts = mapToSecs (getDateFromString model.formStarts)
        maybeEnds = mapToSecs (getDateFromString model.formEnds)
      in
      case (maybeStarts, maybeEnds, model.selectedActivity) of
        (Just starts, Just ends, Just {arrayIndex, activity}) -> 
          ( { model | dialogOpened = False
            , activities = 
                Array.set arrayIndex {activity | starts = starts, ends = ends} model.activities 
            }
          , updateActivity {activity | starts = starts, ends = ends} token)
        _ -> (model, Cmd.none)
    LoadedActivities activitiesResult ->
      case activitiesResult of
        Ok activities -> ({model | activities = activities}, Cmd.none)
        _ -> (model, Cmd.none)
  
view : Model -> Html Msg
view model = 
  div []
  [ DataTable.dataTable DataTable.config
    { thead =
        [ DataTable.row []
          [ DataTable.cell [] [ text "Naziv" ] 
          , DataTable.cell [] [ text "Opis" ] 
          , DataTable.cell [] [ text "Od" ] 
          , DataTable.cell [] [ text "Do" ] 
          , DataTable.cell [] [ text "Poeni" ]
          ]
        ]
    , tbody =
        ( Array.toList <| Array.indexedMap ( activityTabelView model.zone ) model.activities )
    }
  , Dialog.dialog
        (Dialog.config
            |> Dialog.setOpen model.dialogOpened
            |> Dialog.setOnClose Closed
        )
        { title = Nothing
        , content = [taskForm model]
        , actions = []
        }
  ]

activityTabelView : Zone -> Int -> StudentsActivity -> DataTable.Row Msg
activityTabelView zone id task =
  let
    displayDate = dateView Display zone 
    starts = displayDate (task.starts * 1000)
    ends = displayDate (task.ends * 1000)
    points = if task.points == 0 then "/" else String.fromInt task.points

    editBtn = IconButton.iconButton
        (IconButton.config |> IconButton.setOnClick (EditTask id))
        (IconButton.icon "edit")
  in
  DataTable.row []
    [ DataTable.cell [] [ text task.name ]
    , DataTable.cell [] [ text task.description ]
    , DataTable.cell [] [ text starts ]
    , DataTable.cell [] [ text ends ]
    , DataTable.cell [] [ text points ]
    , DataTable.cell [] [ editBtn ]
    ]


taskForm : Model -> Html Msg
taskForm model = 
  let
    viewInput inputType label msg val = 
      formInput 
      { inputType = inputType
      , class_ = "task-input"
      , label = label
      , msg = msg
      , val = val
      } 

    submitBtn = 
      submitButton 
        { text = "Sačuvaj"
        , disabled = model.formProcessing
        , icon = Just (Button.icon "save")
        }
    
    closeBtn = 
      IconButton.iconButton
        (IconButton.config |> IconButton.setOnClick Closed)
        (IconButton.icon "close")

    
    header = 
      div [class "dialog-header"]
      [ h4 [Typography.headline6] [text "Izmena zadatka"]
      , closeBtn
      ]
  in
  div []
    [ header
    , form [ onSubmit SaveTask]
        [div [style "display" "flex"]
          [ viewInput "date" ( Just "Od") Starts (Just model.formStarts)
          , viewInput "date" ( Just "Do") Ends (Just model.formEnds)
          ]
        , submitBtn
        , progressLine model.formProcessing
        ]
    ]

dateView : ViewMode -> Zone -> Int -> String
dateView mode zone timeInMillis = 
  let
    time = Time.millisToPosix timeInMillis
    day = String.padLeft 2 '0' <| String.fromInt (Time.toDay zone time)
    month = toTwoDigitMonth (Time.toMonth zone time)
    year = String.fromInt (Time.toYear zone time)
  in
  case mode of 
    Display -> day ++ "." ++ month ++ "." ++ year ++ "."
    Edit -> year ++ "-" ++ month ++ "-" ++ day


toTwoDigitMonth : Month -> String
toTwoDigitMonth month =
  case month of
    Jan -> "01"
    Feb -> "02"
    Mar -> "03"
    Apr -> "04"
    May -> "05"
    Jun -> "06"
    Jul -> "07"
    Aug -> "08"
    Sep -> "09"
    Oct -> "10"
    Nov -> "11"
    Dec -> "12"

intToMonth : Int -> Maybe Month
intToMonth month =
   case month of
    1 -> Just Jan
    2 -> Just Feb
    3 -> Just Mar
    4 -> Just Apr
    5 -> Just May
    6 -> Just Jun
    7 -> Just Jul
    8 -> Just Aug
    9 -> Just Sep
    10 -> Just Oct
    11 -> Just Nov
    12 -> Just Dec
    _ -> Nothing


getDateFromString : String -> Maybe Calendar.Date
getDateFromString stringTime = 
  case List.map String.toInt (String.split "-" stringTime) of
    [ Just year, Just month, Just day] ->
      (intToMonth month) |> Maybe.andThen 
        (\m -> Calendar.fromRawParts {year = year, month = m, day = day} ) 
        
    _ -> Nothing


activitiesCmd : Model -> String -> Cmd Msg
activitiesCmd model token =
  if Array.isEmpty model.activities then 
    getActivities token
  else 
    Cmd.none

getActivities : String -> Cmd Msg
getActivities token = 
  Api.get 
    { url = Api.endpoints.activities
    , token = token
    , expect = Http.expectJson LoadedActivities (field "data" (array StudentsActivity.decodeActivity))
    }

updateActivity :  StudentsActivity -> String -> Cmd Msg
updateActivity activity token = 
    Api.put
      { url =  Api.endpoints.activities ++ "/" ++ (String.fromInt activity.id)
      , token = token
      , body = Http.jsonBody (StudentsActivity.encodeActivity activity)
      , expect = Http.expectJson LoadedActivities (field "data" (array StudentsActivity.decodeActivity))
      }