module Professor.Settings exposing (..)

import Api
import Array exposing (Array)
import Calendar
import Html exposing (Html, div, form, h4, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onSubmit)
import Http
import Json.Decode exposing (array, field)
import Material.Button as Button
import Material.DataTable as DataTable
import Material.Dialog as Dialog
import Material.IconButton as IconButton
import Material.Typography as Typography
import Maybe
import StudentsActivity exposing (StudentsActivity)
import Task
import Time exposing (Month(..), Zone)
import Util exposing (ViewMode(..), dateView, formInput, getDateFromString, progressLine, submitButton)


type alias Model =
    { zone : Zone
    , activities : Array StudentsActivity
    , dialogOpened : Bool
    , selectedActivity : Maybe SelectedActivity
    , formStarts : String
    , formEnds : String
    , formProcessing : Bool
    }


type alias SelectedActivity =
    { arrayIndex : Int
    , activity : StudentsActivity
    }


init : Model
init =
    Model Time.utc (Array.fromList []) False Nothing "" "" False


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
        AdjustTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        Closed ->
            ( { model | dialogOpened = False }, Cmd.none )

        EditTask index ->
            let
                dateEdit =
                    dateView Edit model.zone
            in
            case Array.get index model.activities of
                Nothing ->
                    ( model, Cmd.none )

                Just activity ->
                    ( { model
                        | dialogOpened = True
                        , selectedActivity = Just { arrayIndex = index, activity = activity }
                        , formStarts = dateEdit (activity.starts * 1000)
                        , formEnds = dateEdit (activity.ends * 1000)
                        , formProcessing = False
                      }
                    , Cmd.none
                    )

        Starts value ->
            ( { model | formStarts = value }, Cmd.none )

        Ends value ->
            ( { model | formEnds = value }, Cmd.none )

        SaveTask ->
            let
                millisToSec millis =
                    millis // 1000

                mapToSecs =
                    Maybe.map (millisToSec << Calendar.toMillis)

                maybeStarts =
                    mapToSecs (getDateFromString model.formStarts)

                maybeEnds =
                    mapToSecs (getDateFromString model.formEnds)
            in
            case ( maybeStarts, maybeEnds, model.selectedActivity ) of
                ( Just starts, Just ends, Just { arrayIndex, activity } ) ->
                    ( { model
                        | dialogOpened = False
                        , activities =
                            Array.set arrayIndex { activity | starts = starts, ends = ends } model.activities
                      }
                    , updateActivity { activity | starts = starts, ends = ends } token
                    )

                _ ->
                    ( model, Cmd.none )

        LoadedActivities activitiesResult ->
            case activitiesResult of
                Ok activities ->
                    ( { model | activities = activities }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


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
                Array.toList <| Array.indexedMap (activityTabelView model.zone) model.activities
            }
        , Dialog.dialog
            (Dialog.config
                |> Dialog.setOpen model.dialogOpened
            )
            { title = Nothing
            , content = [ taskForm model ]
            , actions = []
            }
        ]


activityTabelView : Zone -> Int -> StudentsActivity -> DataTable.Row Msg
activityTabelView zone id task =
    let
        displayDate =
            dateView Display zone

        starts =
            displayDate (task.starts * 1000)

        ends =
            displayDate (task.ends * 1000)

        points =
            if task.points == 0 then
                "/"

            else
                String.fromInt task.points

        editBtn =
            IconButton.iconButton
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
            div [ class "dialog-header" ]
                [ h4 [ Typography.headline6 ] [ text "Izmena zadatka" ]
                , closeBtn
                ]
    in
    div []
        [ header
        , form [ onSubmit SaveTask ]
            [ div [ style "display" "flex" ]
                [ viewInput "date" (Just "Od") Starts (Just model.formStarts)
                , viewInput "date" (Just "Do") Ends (Just model.formEnds)
                ]
            , submitBtn
            , progressLine model.formProcessing
            ]
        ]


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


updateActivity : StudentsActivity -> String -> Cmd Msg
updateActivity activity token =
    Api.put
        { url = Api.endpoints.activities ++ "/" ++ String.fromInt activity.id
        , token = token
        , body = Http.jsonBody (StudentsActivity.encodeActivity activity)
        , expect = Http.expectJson LoadedActivities (field "data" (array StudentsActivity.decodeActivity))
        }
