module BoxEditor exposing (boxToBoxEditorHtml)

import Box exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (..)
import Odl exposing (..)
import Types exposing (..)


boxToBoxEditorHtml : Box -> Model -> List (Html Msg)
boxToBoxEditorHtml (Box box) model =
    [ if model.status == EditBoxWarnUnsavedDraft then
        div
            [ class "message is-danger" ]
            [ div
                [ class "message-body" ]
                [ text "You have unsaved draft. Apply the changes or press escape again to discard the changes." ]
            ]

      else
        div
            [ class "message" ]
            [ div
                [ class "message-body" ]
                [ text "Press Escape to go back, but any change you make will be discarded unless you apply it." ]
            ]
    , div
        [ class "label" ]
        [ text "Label: " ]
    , input
        [ class "input"
        , attribute
            "value"
            (case box.label of
                Just label ->
                    label

                Nothing ->
                    ""
            )
        , on
            "keyup"
            (Decode.map
                (LabelUpdate box.id)
                targetValue
            )
        ]
        []
    , div
        [ class "label" ]
        [ text
            (if box.type_ == LiquidBox then
                "Content: "

             else
                "Content (ODL): "
            )
        ]
    , textarea
        ([ class "textarea"
         , attribute "rows" "20"
         ]
            ++ (if box.type_ == LiquidBox then
                    [ on
                        "keyup"
                        (Decode.map
                            (LiquidBoxUpdate box.id)
                            targetValue
                        )
                    ]

                else
                    [ on
                        "keyup"
                        (Decode.map
                            SetOdlStringInsideBox
                            targetValue
                        )
                    ]
               )
        )
        [ text
            (if box.type_ == SolidBox then
                model.odlStringInsideBox

             else
                case box.content of
                    Just content ->
                        content

                    Nothing ->
                        ""
            )
        ]
    , button
        [ class "button is-success is-outlined"
        , onClick
            (ApplyOdlInsideBox box.id)
        ]
        [ text "Apply Changes" ]
    ]
