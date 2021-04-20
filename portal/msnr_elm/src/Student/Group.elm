module Student.Group exposing (..)
import Student.Entity exposing (StudentEntity, decodeStudent)
import Html exposing (Html, text, div)
import User.Session exposing (StudentInfo)
import Api
import Json.Decode exposing (field, list)
import Http

import Material.Chip.Input as InputChip
import Material.ChipSet.Input as InputChipSet

import Material.TextField as TextField
import Material.TextField.Icon as TextFieldIcon
import Material.Elevation as Elevation
import Material.List as MList
import Material.List.Item as MListItem
import Material.Dialog as Dialog
import Material.Button as Button 
import Material.Typography as Typography


import Util exposing (emptyHtmlNode)
import Html exposing (span)
import Set exposing (Set)
import Html.Attributes exposing (style)
import Registration exposing (Msg(..))
import Html exposing (h6)
import Html.Attributes exposing (class)

type alias Model =
  { loading : Bool
  , students : List StudentEntity
  , availableStudents : List StudentEntity
  , addedStudentsIds : Set Int
  , search : String
  , dialogOpened : Bool
  }

init : Model
init = Model True [] [] Set.empty "" False

type Msg 
  = LoadedGroup (Result Http.Error (List StudentEntity)) 
  | LoadedStudents (Result Http.Error (List StudentEntity)) 
  | Create
  | GroupCreated
  | Search String
  | ShowDialog
  | ClosedDialog
  | AddStudent Int
  | RemoveStudent Int

initCmd : Bool -> StudentInfo -> String -> Cmd Msg
initCmd isActive {groupId, semesterId} token =
  case (isActive, groupId) of
    (True, Nothing) -> loadAvailableStudents semesterId token
    ( _ , Just id) -> loadGroup id token
    _ -> Cmd.none

update : Msg -> {studentInfo : StudentInfo, token : String } -> Model -> ( Model, Cmd Msg )
update msg {studentInfo} model =
  case msg of
  LoadedStudents result ->
    case result of
      Ok students -> ({model | availableStudents = students}, Cmd.none)
      _ -> (model, Cmd.none)

  ShowDialog -> 
    ({model | dialogOpened = True, addedStudentsIds = Set.fromList [studentInfo.id]}, Cmd.none)

  AddStudent studentId ->
    ({ model | search = ""
      , addedStudentsIds = Set.insert studentId model.addedStudentsIds
     }
    , Cmd.none
    )

  RemoveStudent studentId -> 
    ({ model |   addedStudentsIds = Set.remove studentId model.addedStudentsIds}, Cmd.none)

  Search searchTxt ->
    ({model | search = searchTxt}, Cmd.none)

  ClosedDialog -> ({model | dialogOpened = False}, Cmd.none)

  _ -> (model, Cmd.none)

  

view : Bool -> StudentInfo -> Model -> Html Msg
view isActive {groupId} model = 
  case (isActive, groupId) of
    (True, Nothing) -> 
      div []
      [ span [] [text "Nemate grupu!"]
      , Button.raised 
          (Button.config 
            |> Button.setIcon (Just (Button.icon "group_add"))
            |> Button.setOnClick ShowDialog
          )
          "Napravi grupu"
      , dialogView model   
      ]
    (_, Just _) -> text "Clan ste grupe"
    _ -> text "Jos uvek niste rasporedjeni u grupu"



dialogView : Model ->  Html Msg
dialogView {search, availableStudents, addedStudentsIds, dialogOpened} = 
  let
    emptySearch = String.isEmpty search
    searchFilter = 
      \{firstName, lastName} -> 
        String.contains search firstName || String.contains search lastName 

    (selectedStudents, unselectedStudents)
      = List.partition (\{studentId} -> Set.member studentId addedStudentsIds) availableStudents

    filteredStudents = 
      if emptySearch then
        unselectedStudents
      else
        List.filter searchFilter unselectedStudents 
    listView = 
      case filteredStudents of
        head :: tail ->
          MList.list 
            (MList.config |> MList.setAttributes [Elevation.z1, style "height" "100%"])
            (listItemView  head) (List.map listItemView tail)
        _ -> h6 [Typography.subtitle2, style "text-align" "center"] 
              [ text (if emptySearch then "Nema vise studenata bez grupe" else "Nema takvog studenta")]
  in
  Dialog.dialog
    (Dialog.config
        |> Dialog.setOpen dialogOpened
        |> Dialog.setOnClose ClosedDialog
    )
    { title = (Just "Nova grupa")
    , content = 
        [ TextField.filled
            (TextField.config
              |> TextField.setAttributes [style "width" "100%"]
              |> TextField.setLabel ( Just "Pretraga studenata")
              |> TextField.setOnInput Search 
              |> TextField.setValue ( Just search)
              |> TextField.setTrailingIcon (Just (TextFieldIcon.icon "search"))
            )
        , div [style "height" "150px"] [listView]
        , div [] [chips selectedStudents]
        ]
    , actions = 
        [ Button.outlined 
            (Button.config 
              |> Button.setAttributes [style "margin-right" "5px"]
              |> Button.setDisabled False
              |> Button.setOnClick ClosedDialog
            ) 
            "Odustani"
        , Button.raised
            (Button.config 
                |> Button.setDisabled False
            ) 
            "Napravi"
        ]     
    }

chips : List StudentEntity -> Html Msg
chips students = 
  case students of
    head :: tail ->
      InputChipSet.chipSet []
        (chip False head)
        (List.map (chip True) tail)
    _ -> emptyHtmlNode 


chip : Bool -> StudentEntity -> (String, InputChip.Chip Msg)
chip removable {firstName, lastName, studentId} =
  let
    config =
      if removable then
        InputChip.config |> InputChip.setOnDelete (RemoveStudent studentId)
      else
        InputChip.config
  in
  (String.fromInt studentId, InputChip.chip config (firstName ++ " " ++ lastName))
  
  

listItemView : StudentEntity -> MListItem.ListItem Msg
listItemView {firstName, lastName, studentId} =
  MListItem.listItem 
    (MListItem.config  
      |> MListItem.setOnClick (AddStudent studentId)
    )
    [ text (firstName ++ " " ++ lastName) ]


loadAvailableStudents : Int -> String -> Cmd Msg
loadAvailableStudents _ token =
  Api.get
    { url = Api.endpoints.students ++ "?noGroup"
    -- , url = Api.endpoints.students ++ "?noGroup&semesterId=" ++ (String.fromInt semesterId)
    , token = token
    , expect = Http.expectJson LoadedStudents (field "data" (list decodeStudent))
    }

loadGroup : Int -> String -> Cmd Msg
loadGroup groupId token = 
  Api.get
    { url = Api.endpoints.groups ++ "/" ++ (String.fromInt groupId)
    , token = token
    , expect = Http.expectJson LoadedGroup (field "data" (field "students" (list decodeStudent)))
    }

