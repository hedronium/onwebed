module View exposing (view)

import Box exposing (..)
import BoxEditor exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (..)
import Menu exposing (..)
import Odl exposing (..)
import Types exposing (..)


view : Model -> Html Msg
view model =
    let
        editBoxModal =
            let
                classValue =
                    if model.status == EditBox || model.status == EditBoxWarnUnsavedDraft then
                        "overlay"
                    else
                        "overlay" ++ " invisible"
            in
            [ div
                [ class classValue
                , id "edit_box_overlay"
                ]
                [ div
                    []
                    (let
                        maybeBox =
                            boxById model.selectedBoxId model
                     in
                     case maybeBox of
                        Just (Box box) ->
                            boxToBoxEditorHtml (Box box) model

                        Nothing ->
                            [ text "The box doesn't exist!" ]
                    )
                ]
            ]

        exportModal =
            let
                classValue =
                    if model.status == ViewExportModal then
                        "overlay"
                    else
                        "overlay" ++ " invisible"
            in
            [ div
                [ class classValue
                ]
                [ div
                    []
                    [ textarea
                        [ class "textarea"
                        , Html.Attributes.attribute "rows" "20"
                        , on "blur" (Decode.map SetImport targetValue)
                        ]
                        [ text (documentToJsonString model) ]
                    ]
                ]
            ]

        importModal =
            let
                classValue =
                    if model.status == ViewImportModal then
                        "overlay"
                    else
                        "overlay" ++ " invisible"
            in
            [ div
                [ class classValue
                ]
                [ div
                    []
                    [ textarea
                        [ class "textarea"
                        , Html.Attributes.attribute "rows" "20"
                        , on "blur" (Decode.map SetImport targetValue)
                        ]
                        []
                    , button
                        [ Html.Events.onClick Import
                        , class "button is-success is-outlined"
                        ]
                        [ text "Import" ]
                    ]
                ]
            ]

        odlModal =
            let
                classValue =
                    if model.status == ViewOdl || model.status == ViewOdlWarnUnsavedDraft then
                        "overlay"
                    else
                        "overlay" ++ " invisible"
            in
            [ div
                [ class classValue
                , Html.Attributes.attribute "aria-hidden" "false"
                , id "view_odl_overlay"
                ]
                [ div
                    []
                    [(if model.status == ViewOdlWarnUnsavedDraft then
                        div
                            [ class "message is-danger" ]
                            [ div
                                [ class "message-body" ]
                                [ text "You have an unsaved draft. Apply the changes or press escape again to discard the changes." ]
                            ]

                      else
                        div
                            [ class "message" ]
                            [ div
                                [ class "message-body" ]
                                [ text "Press Escape to go back, but any change you make will be discarded unless you apply it." ]
                            ]
                     )
                    , div
                        [ class "label"
                        ]
                        [ text "Content (ODL):"
                        ]
                    , div
                        [ class "textarea"
                        , id "odl_editor"
                        , attribute "rows" "20"
                        ]
                        [ text "" ]
                    , button
                        [ Html.Events.onClick ApplyOdl
                        , class "button is-success is-outlined"
                        ]
                        [ text "Apply Changes" ]
                    ]
                ]
            ]


        formContent =
            [ input
                [ attribute "type" "hidden"
                , attribute "name" "content"
                , attribute "value" (escapeString (documentToJsonString model))
                ]
                []
            , input
                [ attribute "type" "hidden"
                , attribute "name" "template_content"
                , attribute "value" (escapeString (documentToHtmlString model))
                ]
                []
            , input
                [ attribute "type" "hidden"
                , attribute "name" "name"
                , attribute "value" model.pageName
                ]
                []
            , input
                [ attribute "type" "hidden"
                , attribute "name" "title"
                , attribute "value" model.pageTitle
                ]
                []
            , input
                [ attribute "type" "hidden"
                , attribute "name" "csrfmiddlewaretoken"
                , attribute "value" model.csrfToken
                ]
                []
            ]
    in
    div
        [ id "document"
        ]
        [ Html.form
            [ attribute "method" "POST"
            , attribute "action" ""
            ]
            ([ generateMenu model ]
                ++ formContent
            )
        , div
            []
            ([]
                ++ exportModal
                ++ importModal
                ++ odlModal
                ++ editBoxModal
            )
        , div
            [ id "playground"
            , class "container"
            ]
            (boxesToHtml (boxesByParentId 0 model) model)
        ]
