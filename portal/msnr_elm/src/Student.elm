module Student exposing (..)

import Api
import Array exposing (Array)
import Html exposing (Html, article, div, header, p, span, text)
import Html.Attributes exposing (class)
import Http
import Json.Decode exposing (field, list)
import Material.CircularProgress as CircularProgress
import Material.Elevation as Elevation
import Material.Typography as Typography
import Student.CV as CV exposing (Msg(..))
import Student.Group as Group exposing (Msg(..))
import StudentsActivity exposing (ActivityType(..), StudentsActivity)
import Task
import Time exposing (Zone)
import Url.Parser exposing (fragment)
import User.Session exposing (StudentInfo)
import Util exposing (ViewMode(..), dateView, emptyHtmlNode)

type StudentActivityFragment
    = Group Int StudentsActivity Group.Model
    | Topic StudentsActivity
    | CV Int StudentsActivity CV.Model


type alias Model =
    { zone : Zone
    , currentTimeSec : Int
    , fragments : Array StudentActivityFragment
    , loading : Bool
    , studentInfo : StudentInfo
    }

type Msg
    = CurrentTime Time.Posix
    | AdjustTimeZone Time.Zone
    | LoadedActivities (Result Http.Error (List StudentsActivity))
    | GotGroupMsg Int Group.Msg
    | GotCvMsg Int CV.Msg


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        AdjustTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

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

        GotGroupMsg _ (GroupCreated result) ->
            case result of
                Ok groupId ->
                    let
                        studentInfo =
                            model.studentInfo

                        newStudentInfo =
                            { studentInfo | groupId = Just groupId }
                    in
                    ( { model | studentInfo = newStudentInfo }, Cmd.none )

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

        GotCvMsg index cvMsg ->
            case Array.get index model.fragments of
                Just (CV _ activity cvModel) ->
                    let
                        ( model_, cmd ) =
                            CV.update cvMsg cvModel

                        fragments =
                            Array.set index (CV index activity model_) model.fragments
                    in
                    ( { model | fragments = fragments }, cmd |> Cmd.map (GotCvMsg index) )

                _ ->
                    ( model, Cmd.none )


init : StudentInfo -> Model
init info =
    Model Time.utc 0 Array.empty True info


view : Model -> Html Msg
view ({ fragments, loading, currentTimeSec } as model) =
    if loading then
        CircularProgress.indeterminate CircularProgress.config

    else
        div []
            (List.map (viewFragment model (isActive currentTimeSec)) (Array.toList fragments))


viewFragment :
    Model
    -> (StudentsActivity -> Bool)
    -> StudentActivityFragment
    -> Html Msg
viewFragment { studentInfo, zone } isActive_ fragment =
    case fragment of
        Group index activity model_ ->
            Group.view (isActive_ activity) studentInfo model_
                |> Html.map (GotGroupMsg index)
                |> viewActivity { active = isActive_ activity, zone = zone } activity

        CV index activity model_ ->
            CV.view model_
                |> Html.map (GotCvMsg index)
                |> viewActivity { active = isActive_ activity, zone = zone } activity

        Topic _ ->
            div [] [ text "Topic" ]


viewActivity : { active : Bool, zone : Zone } -> StudentsActivity -> Html Msg -> Html Msg
viewActivity { active, zone } activity activityContent =
    let
        date =
            dateView Display zone (1000 * activity.ends)

        endsInfo =
            if active then
                span [ Typography.subtitle1 ] [ text ("aktivan do: " ++ date) ]

            else
                emptyHtmlNode

        acitvityHeader =
            header []
                [ span [ Typography.headline6 ] [ text activity.name ]
                , endsInfo
                ]
    in
    article [ Elevation.z3, class "student-activity" ]
        [ acitvityHeader
        , p [] [ activityContent ]
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
                    Group index activity (Group.init activity.id studentInfo.id)

                cmd =
                    Cmd.map (GotGroupMsg index) <|
                        Group.initCmd (isActive time activity) studentInfo token
            in
            ( Array.push fragment fragments, cmd :: cmds, index + 1 )

        UploadCV ->
            ( Array.push (CV index activity (CV.init activity.id)) fragments, cmds, index + 1 )

        _ ->
            ( fragments, cmds, index )


initCmd : Model -> String -> Cmd Msg
initCmd model token =
    Cmd.batch
        [ Task.perform AdjustTimeZone Time.here
        , Task.perform CurrentTime Time.now
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
