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
            if model.status == EditBox || model.status == EditBoxWarnUnsavedDraft then
                [ div
                    [ class "overlay"
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

            else
                []

        exportModal =
            if model.status == ViewExportModal then
                [ div
                    [ class "overlay"
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

            else
                []

        importModal =
            if model.status == ViewImportModal then
                [ div
                    [ class "overlay"
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

            else
                []

        odlModal =
            if model.status == ViewOdl then
                [ div
                    [ class "overlay"
                    , Html.Attributes.attribute "aria-hidden" "false"
                    ]
                    [ div
                        []
                        [ div
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

            else
                []

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
