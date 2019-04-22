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
        [ class "column is-narrow" ]
        [ input
            [ type_ "button"
            , Html.Attributes.value menuItemToBeConverted.name
            , class "button"
            , onClick (MenuItemClicked menuItemToBeConverted.machineName)
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
        menuContent =
            if model.status == SolidBoxAdditionShowOptions then
                menuItemsToHtml
                    [ menuItem "+before" "add_solid_box_before"
                    , menuItem "+inside (first)" "add_solid_box_inside_first"
                    , menuItem "+inside (last)" "add_solid_box_inside_last"
                    , menuItem "+after" "add_solid_box_after"
                    ]

            else if model.status == LiquidBoxAdditionShowOptions then
                menuItemsToHtml
                    [ menuItem "+before" "add_liquid_box_before"
                    , menuItem "+inside (first)" "add_liquid_box_inside_first"
                    , menuItem "+inside (last)" "add_liquid_box_inside_last"
                    , menuItem "+after" "add_liquid_box_after"
                    ]

            else if model.status == DuplicateBoxShowOptions then
                menuItemsToHtml
                    [ menuItem "+before" "duplicate_box_before"
                    , menuItem "+inside (first)" "duplicate_box_inside_first"
                    , menuItem "+inside (last)" "duplicate_box_inside_last"
                    , menuItem "+after" "duplicate_box_after"
                    ]

            else if model.status == SolidBoxAdditionBeforeChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box before which you want to insert the new solid box." ]
                ]

            else if model.status == LiquidBoxAdditionBeforeChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box before which you want to insert the new liquid box." ]
                ]

            else if model.status == SolidBoxAdditionAfterChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box after which you want to insert the new solid box." ]
                ]

            else if model.status == LiquidBoxAdditionAfterChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box after which you want to insert the new liquid box." ]
                ]

            else if model.status == SolidBoxAdditionInsideFirstChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box inside which you want to insert the new solid box as the first item." ]
                ]

            else if model.status == SolidBoxAdditionInsideLastChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box inside which you want to insert the new solid box as the last item." ]
                ]

            else if model.status == RemoveLabelChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box whose label you want to be removed." ]
                ]

            else if model.status == EditBoxChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box which you want to edit." ]
                ]

            else if model.status == AddLabelChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box you want to add the new label in." ]
                ]

            else if model.status == RemoveBoxChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box which you want to be removed." ]
                ]

            else if model.status == DuplicateBoxChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box which you want to duplicate." ]
                ]

            else if model.status == DuplicateBoxBeforeChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box before which you want to place the duplicated box." ]
                ]

            else if model.status == DuplicateBoxInsideFirstChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box inside which you want to place the duplicated box as the first item." ]
                ]

            else if model.status == DuplicateBoxInsideLastChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box inside which you want to place the duplicated box as the last item." ]
                ]

            else if model.status == DuplicateBoxAfterChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box after which you want to place the duplicated box." ]
                ]

            else if model.status == MoveBoxChooseBox then
                [ div
                    [ class "column" ]
                    [ text "Choose box which you want to move." ]
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
            [ div
                [ id "menu_header"
                , class "columns is-variable is-1 is-vcentered"
                ]
                [ div
                    [ class "column is-narrow" ]
                    [ a
                        [ href "../"
                        , class "level-item button"
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
                    ]
                , div
                    [ class "column is-narrow" ]
                    [ a
                        [ class "level-item button"
                        , attribute "href" ("../../" ++ model.pageName)
                        , attribute "target" "__parent"
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
                    ]
                , div
                    [ class "column is-narrow" ]
                    [ button
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
                    ]
                , div
                    [ class "column is-narrow" ]
                    [ b
                        [ class "level-item" ]
                        [ text "Name:" ]
                    ]
                , div
                    [ class "column is-narrow" ]
                    [ span
                        [ class "level-item" ]
                        [ div
                            [ contenteditable True
                            , on "blur" (Decode.map PageNameChanged innerHtmlDecoder)
                            ]
                            [ text model.pageName ]
                        ]
                    ]
                , div
                    [ class "column is-narrow" ]
                    [ b
                        [ class "level-item" ]
                        [ text "Title:" ]
                    ]
                , div
                    [ class "column is-narrow" ]
                    [ span
                        [ class "level-item" ]
                        [ div
                            [ contenteditable True
                            , on "blur" (Decode.map PageTitleChanged innerHtmlDecoder)
                            ]
                            [ text model.pageTitle ]
                        ]
                    ]
                ]
            ]
    in
    nav
        [ class "main-menu"
        , id "menu"
        ]
        [ div
            [ class "container" ]
            menuHeader

        --, hr
        --    []
        --    []
        , div
            [ class "container" ]
            [ div
                [ class "columns is-variable is-1" ]
                menuContent
            ]
        ]
