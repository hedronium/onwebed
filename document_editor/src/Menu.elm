module Menu exposing (generateMenu, menuItem, menuItemToHtml, menuItemsToHtml)

import Box exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (..)
import Types exposing (..)


menuItem : String -> String -> MenuItem
menuItem name machineName =
    { name = name
    , machineName = machineName
    }



-- menu item


menuItemToHtml : MenuItem -> Html Msg
menuItemToHtml menuItemToBeConverted =
    div
        []
        [ input
            [ type_ "button"
            , Html.Attributes.value menuItemToBeConverted.name
            , class "button"
            , onClick (MenuItemClick menuItemToBeConverted.machineName)
            ]
            []
        ]



-- menu items


menuItemsToHtml : List MenuItem -> List (Html Msg)
menuItemsToHtml menuItemsToBeConverted =
    List.map menuItemToHtml menuItemsToBeConverted


generateMenu : Model -> Html Msg
generateMenu model =
    let
        menuBody =
            if model.status == SolidBoxAdditionOptions then
                menuItemsToHtml
                    [ menuItem "+ before" "add_solid_box_before"
                    , menuItem "+ inside (first)" "add_solid_box_inside_first"
                    , menuItem "+ inside (last)" "add_solid_box_inside_last"
                    , menuItem "+ after" "add_solid_box_after"
                    ]

            else if model.status == LiquidBoxAdditionOptions then
                menuItemsToHtml
                    [ menuItem "+ before" "add_liquid_box_before"
                    , menuItem "+ inside (first)" "add_liquid_box_inside_first"
                    , menuItem "+ inside (last)" "add_liquid_box_inside_last"
                    , menuItem "+ after" "add_liquid_box_after"
                    ]

            else if model.status == DuplicateBoxOptions then
                menuItemsToHtml
                    [ menuItem "+ before" "duplicate_box_before"
                    , menuItem "+ inside (first)" "duplicate_box_inside_first"
                    , menuItem "+ inside (last)" "duplicate_box_inside_last"
                    , menuItem "+ after" "duplicate_box_after"
                    ]

            else if model.status == SolidBoxAdditionBeforeBoxSelection then
                [ div
                    []
                    [ text "Choose box before which you want to insert the new solid box." ]
                ]

            else if model.status == LiquidBoxAdditionBeforeBoxSelection then
                [ div
                    []
                    [ text "Choose box before which you want to insert the new liquid box." ]
                ]

            else if model.status == SolidBoxAdditionAfterBoxSelection then
                [ div
                    []
                    [ text "Choose box after which you want to insert the new solid box." ]
                ]

            else if model.status == LiquidBoxAdditionAfterBoxSelection then
                [ div
                    []
                    [ text "Choose box after which you want to insert the new liquid box." ]
                ]

            else if model.status == SolidBoxAdditionInsideFirstBoxSelection then
                [ div
                    []
                    [ text "Choose box inside which you want to insert the new solid box as the first item." ]
                ]

            else if model.status == SolidBoxAdditionInsideLastBoxSelection then
                [ div
                    []
                    [ text "Choose box inside which you want to insert the new solid box as the last item." ]
                ]

            else if model.status == EditBoxBoxSelection then
                [ div
                    []
                    [ text "Choose box which you want to edit." ]
                ]

            else if model.status == DuplicateBoxBoxSelection then
                [ div
                    []
                    [ text "Choose box which you want to duplicate." ]
                ]

            else if model.status == DuplicateBoxBeforeBoxSelection then
                [ div
                    []
                    [ text "Choose box before which you want to place the duplicated box." ]
                ]

            else if model.status == DuplicateBoxInsideFirstBoxSelection then
                [ div
                    []
                    [ text "Choose box inside which you want to place the duplicated box as the first item." ]
                ]

            else if model.status == DuplicateBoxInsideLastBoxSelection then
                [ div
                    []
                    [ text "Choose box inside which you want to place the duplicated box as the last item." ]
                ]

            else if model.status == DuplicateBoxAfterBoxSelection then
                [ div
                    []
                    [ text "Choose box after which you want to place the duplicated box." ]
                ]

            else if model.status == MoveBoxBoxSelection then
                [ div
                    []
                    [ text "Choose box which you want to move." ]
                ]

            else if model.status == RemoveBoxBoxSelection then
                [ div
                    []
                    [ text "Choose box which you want to remove." ]
                ]

            else
                case model.menuMessage of
                    Just justMessage ->
                        [ div
                            [ class "column" ]
                            [ text justMessage ]
                        ]

                    Nothing ->
                        menuItemsToHtml model.menu

        menuHeader =
            [ a
                [ href "../"
                , class "button is-outlined"
                ]
                [ span
                    [ class "icon is-small" ]
                    [ i
                        [ class "fas fa-arrow-left" ]
                        []
                    ]
                , span
                    []
                    [ text "back" ]
                ]
            , a
                [ attribute "href" ("../../" ++ model.pageName)
                , attribute "target" "__parent"
                , class "button is-outlined"
                ]
                [ span
                    [ class "icon is-small" ]
                    [ i
                        [ class "fas fa-eye" ]
                        []
                    ]
                , span
                    []
                    [ text "view" ]
                ]
            , button
                [ class "button is-success is-outlined"
                , attribute "type" "submit"
                ]
                [ span
                    [ class "icon is-small" ]
                    [ i
                        [ class "fas fa-save" ]
                        []
                    ]
                , span
                    []
                    [ text "save" ]
                ]
            , div
                [ class "input-field" ]
                [ b
                    []
                    [ text "Name:" ]
                , span
                    []
                    [ div
                        [ contenteditable True
                        , on "blur" (Decode.map PageNameChange innerHtmlDecoder)
                        ]
                        [ text model.pageName ]
                    ]
                ]
            , div
                [ class "input-field" ]
                [ b
                    []
                    [ text "Title:" ]
                , span
                    []
                    [ div
                        [ contenteditable True
                        , on "blur" (Decode.map PageTitleChange innerHtmlDecoder)
                        ]
                        [ text model.pageTitle ]
                    ]
                ]
            ]
    in
    nav
        [ class "main-menu"
        , id "menu"
        ]
        [ div
            [ class "container"
            ]
            menuHeader
        , div
            [ class "container"
            ]
            menuBody
        ]
