module Box exposing (addLabel, boxById, boxByIdStep, boxSetLabel, boxToHtml, boxToHtmlString, boxToJson, boxesByParentId, boxesToHtml, documentToHtmlString, documentToJsonString, documentWithOneBox, duplicateBox, duplicateBoxAfter, duplicateBoxBefore, duplicateBoxInsideFirst, duplicateBoxInsideLast, duplicateBoxStep, escapeString, generateBox, highestBoxId, indexOfBoxById, indexOfBoxByIdStep, innerHtmlDecoder, insertBoxAfter, insertBoxBefore, insertBoxByIndex, insertBoxInsideFirst, insertBoxInsideLast, isDocumentEmpty, jsonStringToDocument, labelToHtml, liquidBoxToHtml, processBoxType, removeBox, removeBoxStep, removeBoxes, removeLabel, updateBoxContent, updateBoxLabel)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import LabelProcessor exposing (..)
import Types exposing (..)


documentWithOneBox : List Box
documentWithOneBox =
    [ generateBox 1 (Just "div") Nothing 0 SolidBox ]


highestBoxId : List Box -> Maybe Int
highestBoxId document =
    let
        boxIds =
            List.map
                (\(Box box) ->
                    box.id
                )
                document
    in
    List.maximum boxIds


innerHtmlDecoder : Decoder String
innerHtmlDecoder =
    Decode.at [ "target", "innerHTML" ] Decode.string



-- generate box


generateBox : Int -> Maybe String -> Maybe String -> Int -> BoxType -> Box
generateBox id label content parent type_ =
    let
        labelElements =
            case label of
                Nothing ->
                    []

                Just label_ ->
                    processLabel label_
    in
    Box
        { id = id
        , label = label
        , labelElements = labelElements
        , content = content
        , parent = parent
        , type_ = type_
        }



-- generate class of box


processBoxType : BoxType -> String
processBoxType boxTypeValue =
    case boxTypeValue of
        SolidBox ->
            "solid_box"

        LiquidBox ->
            "liquid_box"



-- convert box to html


boxToHtml : Model -> Box -> Html Msg
boxToHtml model (Box boxToBeConvertedToHtml) =
    let
        label =
            case boxToBeConvertedToHtml.label of
                Just justLabel ->
                    [ labelToHtml justLabel (Box boxToBeConvertedToHtml) ]

                Nothing ->
                    []

        restOfContent =
            if boxToBeConvertedToHtml.type_ == LiquidBox then
                -- handle liquid boxes
                [ liquidBoxToHtml
                    (Maybe.withDefault
                        ""
                        boxToBeConvertedToHtml.content
                    )
                    (Box boxToBeConvertedToHtml)
                ]

            else
                -- handle solid boxes
                let
                    children =
                        boxesByParentId boxToBeConvertedToHtml.id model
                in
                boxesToHtml children model

        attributes =
            if model.status == SolidBoxAdditionBeforeBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( SolidBoxAdditionBefore boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == LiquidBoxAdditionBeforeBoxSelection && boxToBeConvertedToHtml.type_ == LiquidBox then
                [ stopPropagationOn "click" (Decode.succeed ( LiquidBoxAdditionBefore boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == SolidBoxAdditionAfterBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( SolidBoxAdditionAfter boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == LiquidBoxAdditionAfterBoxSelection && boxToBeConvertedToHtml.type_ == LiquidBox then
                [ stopPropagationOn "click" (Decode.succeed ( LiquidBoxAdditionAfter boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == SolidBoxAdditionInsideFirstBoxSelection && boxToBeConvertedToHtml.type_ == SolidBox then
                [ stopPropagationOn "click" (Decode.succeed ( SolidBoxAdditionInsideFirst boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == LiquidBoxAdditionInsideFirstBoxSelection && boxToBeConvertedToHtml.type_ == SolidBox then
                [ stopPropagationOn "click" (Decode.succeed ( LiquidBoxAdditionInsideFirst boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == SolidBoxAdditionInsideLastBoxSelection && boxToBeConvertedToHtml.type_ == SolidBox then
                [ stopPropagationOn "click" (Decode.succeed ( SolidBoxAdditionInsideLast boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == LiquidBoxAdditionInsideLastBoxSelection && boxToBeConvertedToHtml.type_ == SolidBox then
                [ stopPropagationOn "click" (Decode.succeed ( LiquidBoxAdditionInsideLast boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == RemoveBoxBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( RemoveBox boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == EditBoxBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( EditBoxSelectBox boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == DuplicateBoxBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( DuplicateBoxSelectBox boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == DuplicateBoxBeforeBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( DuplicateBoxBefore boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == DuplicateBoxInsideFirstBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( DuplicateBoxInsideFirst boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == DuplicateBoxInsideLastBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( DuplicateBoxInsideLast boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == DuplicateBoxAfterBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( DuplicateBoxAfter boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else if model.status == MoveBoxBoxSelection then
                [ stopPropagationOn "click" (Decode.succeed ( MoveBoxSelectBox boxToBeConvertedToHtml.id, True ))
                , stopPropagationOn "mousemove" (Decode.succeed ( SelectBox boxToBeConvertedToHtml.id, True ))
                ]

            else
                []

        classes =
            processBoxType boxToBeConvertedToHtml.type_
                ++ (if model.selectedBoxId == boxToBeConvertedToHtml.id then
                        " selected"

                    else
                        ""
                   )
    in
    -- generate html for the box
    div
        (attributes
            ++ [ class classes
               , id ("box" ++ String.fromInt boxToBeConvertedToHtml.id)
               ]
        )
        (label
            ++ restOfContent
        )



-- convert boxes to html


boxesToHtml : List Box -> Model -> List (Html Msg)
boxesToHtml boxes model =
    List.map (boxToHtml model) boxes



-- get boxes by parent id


boxesByParentId : Int -> Model -> List Box
boxesByParentId parentId model =
    List.filter
        (\(Box box) ->
            if box.parent == parentId then
                True

            else
                False
        )
        model.document



-- set label of box


boxSetLabel : Int -> Maybe String -> List Box -> List Box
boxSetLabel boxId maybeLabel document =
    let
        label =
            case maybeLabel of
                Just justLabel ->
                    justLabel

                Nothing ->
                    ""
    in
    List.map
        (\(Box box) ->
            if box.id == boxId then
                Box
                    { box
                        | label = Just label
                    }

            else
                Box box
        )
        document



-- liquid box to html


liquidBoxToHtml : String -> Box -> Html Msg
liquidBoxToHtml content (Box liquidBox) =
    text content



-- label to html


labelToHtml : String -> Box -> Html Msg
labelToHtml content (Box labelOwner) =
    --span
    --    [ class "box-label" ]
    --    [ div
    --        [ on
    --            "blur"
    --            (Decode.map
    --                (LabelUpdate labelOwner.id)
    --                innerHtmlDecoder
    --            )
    --        , contenteditable True
    --        ]
    --        [ text content ]
    --    ]
    span
        [ class "box-label"
        ]
        [ text content ]


indexOfBoxByIdStep : Int -> List Box -> Int -> Maybe Int
indexOfBoxByIdStep boxBeingSearchedId boxesToSearch step =
    case boxesToSearch of
        [] ->
            Nothing

        (Box boxToSearch) :: restOfBoxesToSearch ->
            if boxToSearch.id == boxBeingSearchedId then
                Just step

            else
                indexOfBoxByIdStep boxBeingSearchedId restOfBoxesToSearch (step + 1)


indexOfBoxById : Int -> Model -> Maybe Int
indexOfBoxById boxBeingSearchedId model =
    indexOfBoxByIdStep boxBeingSearchedId model.document 0


boxByIdStep : Int -> List Box -> Maybe Box
boxByIdStep boxBeingSearchedId boxesToSearch =
    case boxesToSearch of
        [] ->
            Nothing

        (Box boxToSearch) :: restOfBoxesToSearch ->
            if boxToSearch.id == boxBeingSearchedId then
                Just (Box boxToSearch)

            else
                boxByIdStep boxBeingSearchedId restOfBoxesToSearch


boxById : Int -> Model -> Maybe Box
boxById boxBeingSearchedId model =
    boxByIdStep boxBeingSearchedId model.document


insertBoxByIndex : Int -> Int -> BoxType -> Model -> Model
insertBoxByIndex index newBoxParentId type_ model =
    let
        boxesLeft =
            List.take index model.document

        boxesRight =
            List.drop index model.document

        newBoxId =
            Maybe.withDefault
                0
                (highestBoxId model.document)
                + 1

        newBox =
            case type_ of
                SolidBox ->
                    generateBox newBoxId (Just "div") Nothing newBoxParentId type_

                LiquidBox ->
                    generateBox newBoxId Nothing (Just "Hello!") newBoxParentId type_
    in
    { model
        | document = List.append boxesLeft (newBox :: boxesRight)
    }


insertBoxBefore : Int -> BoxType -> Model -> Model
insertBoxBefore insertBeforeBoxId type_ model =
    let
        insertBeforeBox =
            boxById insertBeforeBoxId model

        newBoxParentId =
            case insertBeforeBox of
                Just (Box justInsertBeforeBox) ->
                    justInsertBeforeBox.parent

                Nothing ->
                    0

        newBoxIndex =
            Maybe.withDefault 0 (indexOfBoxById insertBeforeBoxId model)
    in
    insertBoxByIndex
        newBoxIndex
        newBoxParentId
        type_
        { model
            | status = Default
            , selectedBoxId = 0
        }


duplicateBoxStep : List Box -> List Box -> Model -> Model
duplicateBoxStep oldBoxes newBoxes model =
    let
        maybeFirstOldBox =
            List.head oldBoxes

        restOfOldBoxes =
            Maybe.withDefault [] (List.tail oldBoxes)

        maybeFirstNewBox =
            List.head newBoxes

        restOfNewBoxes =
            Maybe.withDefault [] (List.tail newBoxes)
    in
    case maybeFirstOldBox of
        Nothing ->
            model

        Just (Box firstOldBox) ->
            case maybeFirstNewBox of
                Nothing ->
                    model

                Just (Box firstNewBox) ->
                    -- old and new boxes do exist
                    let
                        childrenOfFirstOldBox =
                            boxesByParentId firstOldBox.id model

                        lastBoxId =
                            Maybe.withDefault -1 (highestBoxId model.document)

                        -- model with added firstNewBox
                        addedFirstNewBox =
                            case boxById firstNewBox.id model of
                                Just (Box fnb) ->
                                    model

                                Nothing ->
                                    insertBoxByIndex
                                        (lastBoxId + 1)
                                        firstNewBox.parent
                                        firstOldBox.type_
                                        model

                        newFirstNewBox =
                            case boxById firstNewBox.id model of
                                Just (Box fnb2) ->
                                    Box fnb2

                                Nothing ->
                                    Maybe.withDefault (Box firstNewBox) (boxById (lastBoxId + 1) addedFirstNewBox)

                        newFirstNewBoxId =
                            case newFirstNewBox of
                                Box b ->
                                    b.id

                        -- document after setting the content and label
                        updatedContentAndLabel =
                            List.map
                                (\(Box box) ->
                                    if box.id == newFirstNewBoxId && box.type_ == LiquidBox then
                                        Box
                                            { box
                                                | content = firstOldBox.content
                                                , label = firstOldBox.label
                                                , labelElements = processLabel (Maybe.withDefault "" firstOldBox.label)
                                            }

                                    else if box.id == newFirstNewBoxId && box.type_ == SolidBox then
                                        Box
                                            { box
                                                | label = firstOldBox.label
                                                , labelElements = processLabel (Maybe.withDefault "" firstOldBox.label)
                                            }

                                    else
                                        Box box
                                )
                                addedFirstNewBox.document

                        childrenOfFirstNewBox =
                            List.map
                                (\(Box child) ->
                                    Box
                                        { child
                                            | parent = newFirstNewBoxId
                                            , id = 0
                                        }
                                )
                                childrenOfFirstOldBox
                    in
                    duplicateBoxStep
                        (restOfOldBoxes ++ childrenOfFirstOldBox)
                        (restOfNewBoxes ++ childrenOfFirstNewBox)
                        { addedFirstNewBox
                            | document = updatedContentAndLabel
                        }


duplicateBox : Int -> Int -> Model -> Model
duplicateBox newBoxId oldBoxId model =
    let
        maybeNewBox =
            boxById newBoxId model

        maybeBoxToDuplicate =
            boxById (Maybe.withDefault 0 model.duplicateSubjectId) model
    in
    case maybeNewBox of
        Nothing ->
            model

        Just (Box newBox) ->
            case maybeBoxToDuplicate of
                Nothing ->
                    model

                Just (Box boxToDuplicate) ->
                    duplicateBoxStep
                        [ Box boxToDuplicate ]
                        [ Box newBox ]
                        model


duplicateBoxBefore : Int -> Model -> Model
duplicateBoxBefore duplicateBeforeId model =
    let
        boxToDuplicate =
            boxById
                (Maybe.withDefault 1 model.duplicateSubjectId)
                model

        newModel =
            insertBoxBefore
                duplicateBeforeId
                (case boxToDuplicate of
                    Just (Box box) ->
                        box.type_

                    Nothing ->
                        SolidBox
                )
                model

        maybeNewBoxId =
            highestBoxId newModel.document
    in
    case maybeNewBoxId of
        Nothing ->
            model

        Just newBoxId ->
            case newModel.duplicateSubjectId of
                Nothing ->
                    newModel

                Just duplicateSubjectId ->
                    duplicateBox newBoxId duplicateSubjectId newModel


duplicateBoxInsideFirst : Int -> Model -> Model
duplicateBoxInsideFirst duplicateInsideFirstId model =
    let
        boxToDuplicate =
            boxById
                (Maybe.withDefault 1 model.duplicateSubjectId)
                model

        newModel =
            insertBoxInsideFirst
                duplicateInsideFirstId
                (case boxToDuplicate of
                    Just (Box box) ->
                        box.type_

                    Nothing ->
                        SolidBox
                )
                model

        maybeNewBoxId =
            highestBoxId newModel.document
    in
    case maybeNewBoxId of
        Nothing ->
            model

        Just newBoxId ->
            case newModel.duplicateSubjectId of
                Nothing ->
                    newModel

                Just duplicateSubjectId ->
                    duplicateBox newBoxId duplicateSubjectId newModel


duplicateBoxInsideLast : Int -> Model -> Model
duplicateBoxInsideLast duplicateInsideLastId model =
    let
        boxToDuplicate =
            boxById
                (Maybe.withDefault 1 model.duplicateSubjectId)
                model

        newModel =
            insertBoxInsideLast
                duplicateInsideLastId
                (case boxToDuplicate of
                    Just (Box box) ->
                        box.type_

                    Nothing ->
                        SolidBox
                )
                model

        maybeNewBoxId =
            highestBoxId newModel.document
    in
    case maybeNewBoxId of
        Nothing ->
            model

        Just newBoxId ->
            case newModel.duplicateSubjectId of
                Nothing ->
                    newModel

                Just duplicateSubjectId ->
                    duplicateBox newBoxId duplicateSubjectId newModel


duplicateBoxAfter : Int -> Model -> Model
duplicateBoxAfter duplicateAfterId model =
    let
        boxToDuplicate =
            boxById
                (Maybe.withDefault 1 model.duplicateSubjectId)
                model

        newModel =
            insertBoxAfter
                duplicateAfterId
                (case boxToDuplicate of
                    Just (Box box) ->
                        box.type_

                    Nothing ->
                        SolidBox
                )
                model

        maybeNewBoxId =
            highestBoxId newModel.document
    in
    case maybeNewBoxId of
        Nothing ->
            model

        Just newBoxId ->
            case newModel.duplicateSubjectId of
                Nothing ->
                    newModel

                Just duplicateSubjectId ->
                    duplicateBox newBoxId duplicateSubjectId newModel


insertBoxAfter : Int -> BoxType -> Model -> Model
insertBoxAfter boxId type_ model =
    let
        subject =
            boxById boxId model

        newBoxParentId =
            case subject of
                Just (Box justInsertBeforeBox) ->
                    justInsertBeforeBox.parent

                Nothing ->
                    0

        newBoxIndex =
            case indexOfBoxById boxId model of
                Just index ->
                    index + 1

                Nothing ->
                    0
    in
    insertBoxByIndex
        newBoxIndex
        newBoxParentId
        type_
        { model
            | status = Default
            , selectedBoxId = 0
        }


insertBoxInsideFirst : Int -> BoxType -> Model -> Model
insertBoxInsideFirst boxId type_ model =
    let
        subject =
            boxById boxId model

        newBoxParentId =
            case subject of
                Just (Box justInsertBeforeBox) ->
                    justInsertBeforeBox.id

                Nothing ->
                    0

        newBoxIndex =
            case indexOfBoxById boxId model of
                Just index ->
                    index + 1

                Nothing ->
                    0
    in
    insertBoxByIndex
        newBoxIndex
        newBoxParentId
        type_
        { model
            | status = Default
            , selectedBoxId = 0
        }


insertBoxInsideLast : Int -> BoxType -> Model -> Model
insertBoxInsideLast boxId type_ model =
    let
        subject =
            boxById boxId model

        newBoxParentId =
            case subject of
                Just (Box justInsertBeforeBox) ->
                    justInsertBeforeBox.id

                Nothing ->
                    0

        childrenOfSubject =
            boxesByParentId boxId model

        lastChildrenOfSubject =
            List.head (List.drop (List.length childrenOfSubject - 1) childrenOfSubject)

        newBoxIndex =
            case lastChildrenOfSubject of
                Just (Box lastChild) ->
                    case indexOfBoxById lastChild.id model of
                        Just index ->
                            index + 1

                        Nothing ->
                            0

                Nothing ->
                    0
    in
    insertBoxByIndex
        newBoxIndex
        newBoxParentId
        type_
        { model
            | status = Default
            , selectedBoxId = 0
        }


updateBoxLabel : Int -> String -> Box -> Box
updateBoxLabel boxId label (Box box) =
    let
        trimmedLabel =
            String.trim label
    in
    if box.id == boxId then
        if String.length trimmedLabel /= 0 then
            Box
                { box
                    | label = Just label
                    , labelElements = processLabel label
                }

        else
            Box
                { box
                    | label = Nothing
                    , labelElements = processLabel label
                }

    else
        Box box


escapeString : String -> String
escapeString string =
    let
        encodedString =
            Encode.encode 0 (Encode.string string)

        encodedStringLength =
            String.length encodedString
    in
    String.slice 1 (encodedStringLength - 1) encodedString


updateBoxContent : Int -> String -> Box -> Box
updateBoxContent boxId content (Box box) =
    if box.id == boxId then
        Box
            { box
                | content = Just content
            }

    else
        Box box


removeLabel : Int -> Box -> Box
removeLabel boxId (Box box) =
    if box.id == boxId then
        Box
            { box
                | label = Nothing
                , labelElements = []
            }

    else
        Box box


addLabel : Int -> Box -> Box
addLabel boxId (Box box) =
    if box.id == boxId then
        Box
            { box
                | label = Just "div"
                , labelElements = processLabel "div"
            }

    else
        Box box


removeBoxStep : List Int -> Model -> List Box
removeBoxStep boxIds model =
    let
        -- subject and its immediate children removed
        boxes =
            case List.head boxIds of
                Nothing ->
                    model.document

                Just boxId ->
                    List.filter
                        (\(Box box) ->
                            if box.id == boxId || box.parent == boxId then
                                False

                            else
                                True
                        )
                        model.document

        -- note down the children so we can remove their children aswell
        children =
            case List.head boxIds of
                Nothing ->
                    []

                Just boxId ->
                    List.map
                        (\(Box b) ->
                            b.id
                        )
                        (boxesByParentId boxId model)

        newModel =
            { model
                | document = boxes
            }

        newBoxIds =
            List.append (Maybe.withDefault [] (List.tail boxIds)) children
    in
    if List.length newBoxIds == 0 then
        boxes

    else
        removeBoxStep newBoxIds newModel


removeBox : Int -> Model -> List Box
removeBox boxId model =
    removeBoxStep [ boxId ] model


removeBoxes : List Int -> Model -> List Box
removeBoxes boxesIds model =
    if List.isEmpty boxesIds then
        model.document

    else
        let
            head =
                List.head boxesIds

            newDocument =
                case head of
                    Just justHead ->
                        removeBox
                            justHead
                            model

                    Nothing ->
                        model.document

            newModel =
                { model
                    | document = newDocument
                }

            newBoxesIds =
                case List.tail boxesIds of
                    Just justBoxesIds ->
                        justBoxesIds

                    Nothing ->
                        []
        in
        removeBoxes newBoxesIds newModel


boxToHtmlString : Model -> Box -> String
boxToHtmlString model (Box box) =
    let
        boxContentLeft =
            List.foldr
                (++)
                ""
                (List.map labelElementStartingTagToString box.labelElements)

        boxContentRight =
            List.foldl
                (++)
                ""
                (List.map labelElementEndingTagToString box.labelElements)

        boxContentInner =
            if box.type_ == SolidBox then
                List.foldr
                    (++)
                    ""
                    (List.map (boxToHtmlString model) (boxesByParentId box.id model))

            else
                Maybe.withDefault "" box.content
    in
    boxContentLeft ++ boxContentInner ++ boxContentRight


documentToHtmlString : Model -> String
documentToHtmlString model =
    let
        boxesInRoot =
            boxesByParentId 0 model

        boxesInRootStringified =
            List.map (boxToHtmlString model) boxesInRoot

        documentHtmlString =
            List.foldr (++) "" boxesInRootStringified
    in
    documentHtmlString


isDocumentEmpty : Model -> Bool
isDocumentEmpty model =
    if List.length model.document == 0 then
        True

    else
        False


boxToJson : Box -> Encode.Value
boxToJson (Box box) =
    let
        type_ =
            case box.type_ of
                SolidBox ->
                    "solid_box"

                LiquidBox ->
                    "liquid_box"

        --labelElementsJsonStringified =
        --    List.foldr (++) "" (List.map labelElementToJsonStrigified box.labelElements)
    in
    Encode.object
        [ ( "id", Encode.int box.id )
        , ( "label", Encode.string (Maybe.withDefault "" box.label) )
        , ( "content", Encode.string (Maybe.withDefault "" box.content) )
        , ( "parent", Encode.int box.parent )
        , ( "type", Encode.string type_ )

        --, ( "labelElements", Encode.string labelElementsJsonStringified )
        ]


documentToJsonString : Model -> String
documentToJsonString model =
    let
        boxesJsonStringifiedAndListified =
            Encode.list boxToJson model.document
    in
    Encode.encode 0 boxesJsonStringifiedAndListified


jsonStringToDocument : String -> List Box
jsonStringToDocument jsonString =
    let
        boxIdDecoder =
            Decode.field "id" Decode.int

        boxLabelDecoder =
            Decode.field
                "label"
                (Decode.string
                    |> Decode.andThen
                        (\labelString ->
                            if String.length labelString == 0 then
                                Decode.succeed Nothing

                            else
                                Decode.succeed (Just labelString)
                        )
                )

        boxContentDecoder =
            Decode.field
                "content"
                (Decode.string
                    |> Decode.andThen
                        (\content ->
                            if String.length content == 0 then
                                Decode.succeed Nothing

                            else
                                Decode.succeed (Just content)
                        )
                )

        boxParentDecoder =
            Decode.field "parent" Decode.int

        boxTypeDecoder =
            Decode.field
                "type"
                (Decode.string
                    |> Decode.andThen
                        (\typeString ->
                            case typeString of
                                "solid_box" ->
                                    Decode.succeed SolidBox

                                "liquid_box" ->
                                    Decode.succeed LiquidBox

                                _ ->
                                    Decode.succeed SolidBox
                        )
                )

        boxJsonDecoder =
            Decode.map5
                generateBox
                boxIdDecoder
                boxLabelDecoder
                boxContentDecoder
                boxParentDecoder
                boxTypeDecoder

        boxesJsonDecoder =
            Decode.list boxJsonDecoder

        decodedListResult =
            Decode.decodeString boxesJsonDecoder jsonString
    in
    case decodedListResult of
        Ok listOfBoxes ->
            listOfBoxes

        Err err ->
            []
