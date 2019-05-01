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
        export_modal =
            if String.length model.export /= 0 then
                [ div
                    [ class "modal is-active"
                    , id "export"
                    ]
                    [ div
                        [ class "modal-background"
                        , Html.Events.onClick ResetExport
                        ]
                        []
                    , div
                        [ class "modal-content" ]
                        [ div
                            [ class "box" ]
                            [ text model.export ]
                        ]
                    , button
                        [ class "modal-close is-large"
                        , attribute "aria-label" "close"
                        , Html.Events.onClick ResetExport
                        ]
                        []
                    ]
                ]

            else
                []

        import_modal =
            if model.import_ then
                [ div
                    [ class "modal is-active"
                    , id "import"
                    ]
                    [ div
                        [ class "modal-background"
                        , Html.Events.onClick ResetImport
                        ]
                        []
                    , div
                        [ class "modal-content" ]
                        [ div
                            [ class "box" ]
                            [ div
                                [ class "field" ]
                                [ div
                                    [ class "control" ]
                                    [ textarea
                                        [ class "textarea"
                                        , on "blur" (Decode.map SetImport targetValue)
                                        ]
                                        []
                                    ]
                                ]
                            , div
                                [ class "field" ]
                                [ div
                                    [ class "control" ]
                                    [ input
                                        [ Html.Attributes.value "Import"
                                        , Html.Events.onClick Import
                                        , class "button is-success"
                                        ]
                                        []
                                    ]
                                ]
                            ]
                        ]
                    , button
                        [ class "modal-close is-large"
                        , attribute "aria-label" "close"
                        , Html.Events.onClick ResetImport
                        ]
                        []
                    ]
                ]

            else
                []

        odl_modal =
            if model.status == ViewOdl then
                --let
                --    children =
                --        boxesByParentId 0 model
                --    boxesToOdlStrings =
                --        List.map (boxToOdl model 0) children
                --    textareaValue =
                --        List.foldr
                --            (++)
                --            ""
                --            (List.intersperse "\n\n" boxesToOdlStrings)
                --in
                [ div
                    [ class "modal is-active"
                    , id "odl"
                    ]
                    [ div
                        [ class "modal-background"
                        , Html.Events.onClick ResetOdlModal
                        ]
                        []
                    , div
                        [ class "modal-content" ]
                        [ div
                            [ class "box" ]
                            [ div
                                [ class "field" ]
                                [ div
                                    [ class "control" ]
                                    [ textarea
                                        [ class "textarea"
                                        , attribute "rows" "20"
                                        , on "blur" (Decode.map SetOdlString targetValue)
                                        ]
                                        [ text model.odlString ]
                                    ]
                                ]
                            , div
                                [ class "field" ]
                                [ div
                                    [ class "control" ]
                                    [ input
                                        [ Html.Attributes.value "Apply ODL"
                                        , Html.Events.onClick ApplyOdl
                                        , class "button is-success"
                                        ]
                                        []
                                    ]
                                ]
                            ]
                        ]
                    , button
                        [ class "modal-close is-large"
                        , attribute "aria-label" "close"
                        , Html.Events.onClick ResetOdlModal
                        ]
                        []
                    ]
                ]

            else
                []

        form_content =
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
        [ id "document" ]
        [ Html.form
            [ attribute "method" "POST"
            , attribute "action" ""
            ]
            ([ generateMenu model ]
                ++ export_modal
                ++ import_modal
                ++ odl_modal
                ++ form_content
            )
        , div
            [ id "playground"
            , class "container"
            ]
            (if model.status /= EditBox then
                boxesToHtml (boxesByParentId 0 model) model

             else
                let
                    maybeBox =
                        boxById model.selectedBoxId model
                in
                case maybeBox of
                    Just (Box box) ->
                        boxToBoxEditorHtml (Box box) model

                    Nothing ->
                        [ text "The box doesn't exist!" ]
            )
        , input
            [ id "document_validity"
            , attribute "type" "hidden"
            , attribute "value" (String.fromInt model.documentValidity)
            ]
            []
        ]
