module Util exposing (..)

import Calendar
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, required, type_)
import Material.Button as Button exposing (Icon)
import Material.LinearProgress as LinearProgress
import Material.TextField as TextField
import Time exposing (Month(..), Zone)


type ViewMode
    = Display
    | Edit


emptyHtmlNode : Html msg
emptyHtmlNode =
    text ""


formInput : { inputType : String, label : Maybe String, class_ : String, msg : String -> msg, val : Maybe String } -> Html msg
formInput { inputType, label, class_, msg, val } =
    div [ class "form-item" ]
        [ TextField.filled
            (TextField.config
                |> TextField.setLabel label
                |> TextField.setOnInput msg
                |> TextField.setType (Just inputType)
                |> TextField.setAttributes [ class class_, required True ]
                |> TextField.setValue val
            )
        ]


submitButton : { text : String, disabled : Bool, icon : Maybe Icon } -> Html msg
submitButton { text, icon, disabled } =
    div [ class "form-item" ]
        [ Button.raised
            (Button.config
                |> Button.setAttributes [ type_ "submit" ]
                |> Button.setDisabled disabled
                |> Button.setIcon icon
            )
            text
        ]


progressLine : Bool -> Html msg
progressLine isLoading =
    if isLoading then
        LinearProgress.indeterminate LinearProgress.config

    else
        emptyHtmlNode


dateView : ViewMode -> Zone -> Int -> String
dateView mode zone timeInMillis =
    let
        time =
            Time.millisToPosix timeInMillis

        day =
            String.padLeft 2 '0' <| String.fromInt (Time.toDay zone time)

        month =
            toTwoDigitMonth (Time.toMonth zone time)

        year =
            String.fromInt (Time.toYear zone time)
    in
    case mode of
        Display ->
            day ++ "." ++ month ++ "." ++ year ++ "."

        Edit ->
            year ++ "-" ++ month ++ "-" ++ day


toTwoDigitMonth : Month -> String
toTwoDigitMonth month =
    case month of
        Jan ->
            "01"

        Feb ->
            "02"

        Mar ->
            "03"

        Apr ->
            "04"

        May ->
            "05"

        Jun ->
            "06"

        Jul ->
            "07"

        Aug ->
            "08"

        Sep ->
            "09"

        Oct ->
            "10"

        Nov ->
            "11"

        Dec ->
            "12"


intToMonth : Int -> Maybe Month
intToMonth month =
    case month of
        1 ->
            Just Jan

        2 ->
            Just Feb

        3 ->
            Just Mar

        4 ->
            Just Apr

        5 ->
            Just May

        6 ->
            Just Jun

        7 ->
            Just Jul

        8 ->
            Just Aug

        9 ->
            Just Sep

        10 ->
            Just Oct

        11 ->
            Just Nov

        12 ->
            Just Dec

        _ ->
            Nothing


getDateFromString : String -> Maybe Calendar.Date
getDateFromString stringTime =
    case List.map String.toInt (String.split "-" stringTime) of
        [ Just year, Just month, Just day ] ->
            intToMonth month
                |> Maybe.andThen
                    (\m -> Calendar.fromRawParts { year = year, month = m, day = day })

        _ ->
            Nothing
