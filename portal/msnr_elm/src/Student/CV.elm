module Student.CV exposing (..)

import File exposing (File)
import Html exposing (Html, div, input, text)
import Html.Attributes exposing (multiple, type_)
import Html.Events exposing (on)
import Json.Decode as D
import Material.Button as Button
import Task


type alias Model =
    { activityId : Int
    , cvFile : Maybe File
    }


init : Int -> Model
init activityId =
    Model activityId Nothing


type Msg
    = SelectedFile (List File)
    | Upload
    | GotBase64 String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedFile [ file ] ->
            ( { model | cvFile = Just file }, Task.perform GotBase64 (File.toUrl file) )

        Upload ->
            ( model, Cmd.none )

        GotBase64 base64 ->
            Debug.log base64
                ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view _ =
    div []
        [ input
            [ type_ "file"
            , multiple False
            , on "change" (D.map SelectedFile filesDecoder)
            ]
            []
        ]


filesDecoder : D.Decoder (List File)
filesDecoder =
    D.at [ "target", "files" ] (D.list File.decoder)
