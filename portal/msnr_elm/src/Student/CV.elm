module Student.CV exposing (..)

import File exposing (File)
import Html exposing (Html, div, input)
import Html.Attributes exposing (multiple, type_)
import Html.Events exposing (on)
import Http exposing (filePart, stringPart)
import Json.Decode as D
import Material.Button as Button


type alias Model =
    { activityId : Int
    , cvFile : Maybe File
    }


endpoint : String
endpoint =
    "http://localhost:4000/api/cvs"


init : Int -> Model
init activityId =
    Model activityId Nothing


type Msg
    = SelectedFile (List File)
    | Upload
    | Uploaded (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedFile [ file ] ->
            ( { model | cvFile = Just file }, upload model.activityId file )

        Upload ->
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


upload : Int -> File.File -> Cmd Msg
upload activityId file =
    let
        body =
            Http.multipartBody
                [ stringPart "activity_id" (String.fromInt activityId)
                , filePart "file" file
                ]
    in
    Http.request
        { method = "POST"
        , headers = []
        , url = endpoint
        , body = body
        , expect = Http.expectWhatever Uploaded
        , timeout = Nothing
        , tracker = Nothing
        }
