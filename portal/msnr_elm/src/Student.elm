module Student exposing (..)

import Api
import Array exposing (Array)
import Html exposing (Html, div, h2, text)
import Http
import Json.Decode exposing (field, list)
import Material.CircularProgress as CircularProgress
import Professor.Settings exposing (Msg(..))
import Student.Group as Group
import StudentsActivity exposing (ActivityType(..), StudentsActivity)
import Task
import Time
import User.Session exposing (StudentInfo)


type StudentActivityFragment
    = Group Int StudentsActivity Group.Model
    | Topic StudentsActivity
    | CV StudentsActivity


type alias Model =
    { currentTimeSec : Int
    , fragments : Array StudentActivityFragment
    , loading : Bool
    , studentInfo : StudentInfo
    }


type Msg
    = CurrentTime Time.Posix
    | LoadedActivities (Result Http.Error (List StudentsActivity))
    | GotGroupMsg Int Group.Msg


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        CurrentTime posixTime ->
            ( { model | currentTimeSec = Time.posixToMillis posixTime // 1000 }, Cmd.none )

        LoadedActivities activitiesResult ->
            case activitiesResult of
                Ok activities ->
                    let
                        foldFn =
                            getFragmentsAndCommands model.currentTimeSec model.studentInfo token

                        ( fragments, cmds, _ ) =
                            List.foldr foldFn ( Array.empty, [], 0 ) activities
                    in
                    ( { model | loading = False, fragments = fragments }, Cmd.batch cmds )

                _ ->
                    ( model, Cmd.none )

        GotGroupMsg index groupMsg ->
            case Array.get index model.fragments of
                Just (Group _ activity groupModel) ->
                    let
                        ( model_, cmd ) =
                            Group.update groupMsg { studentInfo = model.studentInfo, token = token } groupModel

                        fragments =
                            Array.set index (Group index activity model_) model.fragments
                    in
                    ( { model | fragments = fragments }, cmd |> Cmd.map (GotGroupMsg index) )

                _ ->
                    ( model, Cmd.none )


init : StudentInfo -> Model
init info =
    Model 0 Array.empty True info


view : Model -> Html Msg
view { fragments, loading, studentInfo, currentTimeSec } =
    if loading then
        CircularProgress.indeterminate CircularProgress.config

    else
        div []
            (List.map (viewFragment studentInfo (isActive currentTimeSec)) (Array.toList fragments))


viewFragment :
    StudentInfo
    -> (StudentsActivity -> Bool)
    -> StudentActivityFragment
    -> Html Msg
viewFragment studentInfo isActive_ fragment =
    case fragment of
        Group index activity model_ ->
            Group.view (isActive_ activity) studentInfo model_
                |> Html.map (GotGroupMsg index)
                |> viewActivity activity

        CV _ ->
            div [] [ text "CV" ]

        Topic _ ->
            div [] [ text "Topic" ]


viewActivity : StudentsActivity -> Html Msg -> Html Msg
viewActivity activity activityContent =
    div []
        [ h2 [] [ text activity.name ]
        , div [] [ activityContent ]
        ]


getActivities : String -> Cmd Msg
getActivities token =
    Api.get
        { url = Api.endpoints.activities
        , token = token
        , expect = Http.expectJson LoadedActivities (field "data" (list StudentsActivity.decodeActivity))
        }


getFragmentsAndCommands :
    Int
    -> StudentInfo
    -> String
    -> StudentsActivity
    -> ( Array StudentActivityFragment, List (Cmd Msg), Int )
    -> ( Array StudentActivityFragment, List (Cmd Msg), Int )
getFragmentsAndCommands time studentInfo token activity ( fragments, cmds, index ) =
    case activity.activityType of
        CreateGroup ->
            let
                fragment =
                    Group index activity Group.init

                cmd =
                    Cmd.map (GotGroupMsg index) <|
                        Group.initCmd (isActive time activity) studentInfo token
            in
            ( Array.push fragment fragments, cmd :: cmds, index + 1 )

        _ ->
            ( fragments, cmds, index )


initCmd : Model -> String -> Cmd Msg
initCmd model token =
    Cmd.batch
        [ Task.perform CurrentTime Time.now
        , activitiesCmd model token
        ]


activitiesCmd : Model -> String -> Cmd Msg
activitiesCmd model token =
    if Array.isEmpty model.fragments then
        getActivities token

    else
        Cmd.none


isActive : Int -> StudentsActivity -> Bool
isActive currentTime { ends } =
    ends > currentTime
