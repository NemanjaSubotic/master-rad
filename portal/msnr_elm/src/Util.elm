module Util exposing (..)

import Html exposing (Html, text, div)
import Html.Attributes exposing (class, type_ , required)

import Material.TextField as TextField
import Material.Button as Button exposing (Icon)
import Material.LinearProgress as LinearProgress

type ViewMode = Display | Edit

emptyHtmlNode : Html msg
emptyHtmlNode = text ""

formInput : { inputType : String,  label: Maybe String, class_ : String, msg : String -> msg, val : Maybe String } -> Html msg
formInput {inputType, label, class_, msg, val}  = 
      div [class "form-item"] 
        [TextField.filled
          (TextField.config
              |> TextField.setLabel label
              |> TextField.setOnInput msg
              |> TextField.setType (Just inputType)
              |> TextField.setAttributes [class class_, required True]
              |> TextField.setValue val
          )
        ]

submitButton : {text: String, disabled: Bool, icon: Maybe Icon } -> Html msg
submitButton { text, icon, disabled } =
      div [class "form-item"] 
        [ Button.raised 
            (Button.config 
              |> Button.setAttributes [type_ "submit"]
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
