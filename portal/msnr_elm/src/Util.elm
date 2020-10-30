module Util exposing (viewInput, emptyHtmlNode)

import Html exposing (Html, input, text)
import Html.Attributes exposing (type_, placeholder, value, class)
import Html.Events exposing (onInput)

viewInput : String -> String -> String -> String -> (String -> msg) -> Html msg
viewInput t c p v toMsg =
  input [ type_ t, class c, placeholder p, value v, onInput toMsg ] []

emptyHtmlNode : Html msg
emptyHtmlNode = text ""