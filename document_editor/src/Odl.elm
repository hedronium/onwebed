module Odl exposing (boxContentToOdl, boxToOdl, odlToBoxes)

import Box exposing (..)
import Debug exposing (..)
import LabelProcessor exposing (..)
import Types exposing (..)


boxToOdl : Model -> Int -> Box -> String
boxToOdl model level (Box box) =
    let
        indentation =
            List.foldr
                (++)
                ""
                (List.repeat
                    level
                    "    "
                )

        opening_tag =
            if box.type_ == SolidBox then
                indentation ++ "<! "

            else
                indentation ++ "[! "

        closing_tag =
            if box.type_ == SolidBox then
                indentation ++ " !>"

            else
                " !]"

        label =
            case box.label of
                Just justLabel ->
                    "[ " ++ justLabel ++ " ] "

                Nothing ->
                    ""

        content =
            if box.type_ == SolidBox then
                let
                    odlString =
                        boxContentToOdl
                            (Box box)
                            model
                            (level + 1)
                in
                if String.length (String.trim odlString) == 0 then
                    ""

                else
                    "\n"
                        ++ odlString
                        ++ "\n"

            else
                Maybe.withDefault "" box.content
    in
    opening_tag ++ label ++ content ++ closing_tag


boxContentToOdl : Box -> Model -> Int -> String
boxContentToOdl (Box box) model level =
    let
        children =
            boxesByParentId box.id model

        boxesToOdlStrings =
            List.map (boxToOdl model level) children
    in
    List.foldr
        (++)
        ""
        (List.intersperse "\n\n" boxesToOdlStrings)


currentBoxIdAtLowerLevel : OdlParserModel -> Maybe Int
currentBoxIdAtLowerLevel odlParserModel =
    let
        filteredBoxes =
            List.filter
                (\currentBox ->
                    if currentBox.level == odlParserModel.level - 1 then
                        True

                    else
                        False
                )
                odlParserModel.currentBoxes

        maybeHead =
            List.head filteredBoxes
    in
    case maybeHead of
        Just head ->
            Just head.boxId

        Nothing ->
            Nothing


currentBoxId : OdlParserModel -> Maybe Int
currentBoxId odlParserModel =
    let
        maybeHead =
            List.head (List.reverse odlParserModel.currentBoxes)
    in
    case maybeHead of
        Just head ->
            Just head.boxId

        Nothing ->
            Nothing


removeLastCurrentBox : OdlParserModel -> List CurrentBox
removeLastCurrentBox odlParserModel =
    List.reverse
        (Maybe.withDefault
            []
            (List.tail
                (List.reverse
                    odlParserModel.currentBoxes
                )
            )
        )


odlToBoxes : String -> OdlParserModel -> List Box
odlToBoxes odl odlParserModel =
    if String.length odl == 0 then
        List.map
            (\(Box box) ->
                let
                    labelElements =
                        case box.label of
                            Just label ->
                                processLabel label

                            Nothing ->
                                []

                    content =
                        if box.type_ == LiquidBox then
                            case box.content of
                                Just justContent ->
                                    if String.length justContent > 0 then
                                        Just (String.dropLeft 1 justContent)

                                    else
                                        box.content

                                Nothing ->
                                    box.content

                        else
                            box.content
                in
                Box
                    { box
                        | labelElements = labelElements
                        , content = content
                    }
            )
            odlParserModel.boxes

    else
        let
            newBasket =
                odlParserModel.basket ++ String.left 1 odl

            newModel =
                { odlParserModel
                    | basket = newBasket
                }

            newOdl =
                String.dropLeft 1 odl
        in
        case odlParserModel.status of
            Unresolved ->
                let
                    newModel2 =
                        if String.trimLeft newBasket == "[!" then
                            let
                                id =
                                    Maybe.withDefault 0 (highestBoxId odlParserModel.boxes) + 1

                                newBox =
                                    generateBox
                                        id
                                        Nothing
                                        Nothing
                                        (Maybe.withDefault 0 (currentBoxIdAtLowerLevel newModel))
                                        LiquidBox

                                newBoxes =
                                    odlParserModel.boxes ++ [ newBox ]
                            in
                            { newModel
                                | basket = ""
                                , status = ProcessingLiquidBox
                                , boxes = newBoxes
                                , currentBoxes =
                                    newModel.currentBoxes
                                        ++ [ { boxId = id
                                             , level = newModel.level
                                             }
                                           ]
                            }

                        else if String.trimLeft newBasket == "<!" then
                            let
                                id =
                                    Maybe.withDefault 0 (highestBoxId odlParserModel.boxes) + 1

                                newBox =
                                    generateBox
                                        id
                                        Nothing
                                        Nothing
                                        (Maybe.withDefault 0 (currentBoxIdAtLowerLevel newModel))
                                        SolidBox

                                newBoxes =
                                    odlParserModel.boxes ++ [ newBox ]
                            in
                            { newModel
                                | basket = ""
                                , status = ProcessingSolidBox
                                , boxes = newBoxes
                                , parent = Maybe.withDefault 0 (currentBoxIdAtLowerLevel newModel)
                                , currentBoxes =
                                    newModel.currentBoxes
                                        ++ [ { boxId = id
                                             , level = newModel.level
                                             }
                                           ]
                                , level = newModel.level + 1
                            }

                        else if String.trimLeft newBasket == "!>" then
                            { newModel
                                | status = Unresolved
                                , basket = ""
                                , level = newModel.level - 1
                                , currentBoxes = removeLastCurrentBox newModel
                            }

                        else if String.right 1 newBasket /= "<" && String.right 1 newBasket /= "[" && String.right 1 newBasket /= " " && String.right 1 newBasket /= "!" && String.right 1 newBasket /= ">" then
                            { newModel
                                | basket = ""
                            }

                        else
                            newModel
                in
                odlToBoxes newOdl newModel2

            ProcessingLiquidBox ->
                let
                    newModel2 =
                        if newBasket == " [ " then
                            { newModel
                                | status = ProcessingLabelOfLiquidBox
                                , basket = ""
                            }

                        else if String.right 3 newBasket == " !]" then
                            { newModel
                                | status = Unresolved
                                , basket = ""
                                , boxes =
                                    List.map
                                        (updateBoxContent
                                            (Maybe.withDefault 0 (currentBoxId newModel))
                                            (String.dropRight
                                                3
                                                newModel.basket
                                            )
                                        )
                                        newModel.boxes
                                , currentBoxes = removeLastCurrentBox newModel
                            }

                        else
                            { newModel
                                | boxes =
                                    List.map
                                        (updateBoxContent
                                            (Maybe.withDefault 0 (currentBoxId newModel))
                                            newModel.basket
                                        )
                                        newModel.boxes
                            }
                in
                odlToBoxes newOdl newModel2

            ProcessingSolidBox ->
                let
                    newModel2 =
                        if String.length newBasket <= 3 then
                            if newBasket == " [ " then
                                { newModel
                                    | status = ProcessingLabelOfSolidBox
                                    , basket = ""
                                }

                            else
                                newModel

                        else
                            { newModel
                                | status = Unresolved
                            }
                in
                odlToBoxes newOdl newModel2

            ProcessingLabelOfLiquidBox ->
                if String.right 2 newBasket == " ]" then
                    --let
                    --newOdl2 =
                    --    if String.length (String.trim (String.left 1 newOdl)) == 0 then
                    --        String.dropLeft 1 newOdl
                    --    else
                    --        newOdl
                    --in
                    odlToBoxes
                        newOdl
                        { newModel
                            | basket = ""
                            , status = ProcessingLiquidBox
                        }

                else
                    let
                        newBoxes =
                            boxSetLabel
                                (Maybe.withDefault 0 (currentBoxId newModel))
                                (Just
                                    (String.trim newModel.basket)
                                )
                                newModel.boxes

                        newModel2 =
                            { newModel
                                | boxes = newBoxes
                            }
                    in
                    odlToBoxes newOdl newModel2

            ProcessingLabelOfSolidBox ->
                if String.right 2 newBasket == " ]" then
                    let
                        newOdl2 =
                            if String.length (String.trim (String.left 1 newOdl)) == 0 then
                                String.dropLeft 1 newOdl

                            else
                                newOdl
                    in
                    odlToBoxes
                        newOdl2
                        { newModel
                            | basket = ""
                            , status = Unresolved
                        }

                else
                    let
                        newBoxes =
                            boxSetLabel
                                (Maybe.withDefault 0 (currentBoxId newModel))
                                (Just
                                    (String.trim newModel.basket)
                                )
                                newModel.boxes

                        newModel2 =
                            { newModel
                                | boxes = newBoxes
                            }
                    in
                    odlToBoxes newOdl newModel2
