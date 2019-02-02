module LabelProcessor exposing (LabelElement, labelElementEndingTagToString, labelElementStartingTagToString, processLabel)

import Debug exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ModuleHandler exposing (..)



-- types and initiations


type alias Model =
    { firstCharacter : String
    , restOfCharacters : String
    , labelElement : LabelElement
    , labelElements : List LabelElement
    }


initialModel : Model
initialModel =
    { firstCharacter = ""
    , restOfCharacters = ""
    , labelElement = emptyElement
    , labelElements = []
    }


type alias LabelElement =
    { name : String
    , classes : String
    , id : String
    , htmlAttributes : String
    , endingTag : Bool
    }


emptyElement : LabelElement
emptyElement =
    { name = ""
    , classes = ""
    , id = ""
    , htmlAttributes = ""
    , endingTag = True
    }



-- functions


finalizeElement : Model -> Model
finalizeElement model =
    { model
        | labelElements = List.append model.labelElements [ model.labelElement ]
        , labelElement = emptyElement
    }


isStartOfClass : Model -> Bool
isStartOfClass model =
    let
        secondCharacter =
            String.left 1 model.restOfCharacters
    in
    if
        model.firstCharacter
            == "."
            && (secondCharacter |> isStringWhitespace)
            == False
            && isLastCharacter model
            == False
    then
        True

    else
        False


isStartOfId : Model -> Bool
isStartOfId model =
    let
        secondCharacter =
            String.left 1 model.restOfCharacters
    in
    if
        model.firstCharacter
            == "#"
            && (secondCharacter |> isStringWhitespace)
            == False
            && isLastCharacter model
            == False
    then
        True

    else
        False


isEndingTag : Model -> Bool
isEndingTag model =
    let
        secondCharacter =
            String.left 1 model.restOfCharacters
    in
    if
        model.firstCharacter
            == "."
            && ((secondCharacter |> isStringWhitespace)
                    || isLastCharacter model
               )
    then
        True

    else
        False


isWhitespace : Model -> Bool
isWhitespace model =
    isStringWhitespace model.firstCharacter


isLastCharacter : Model -> Bool
isLastCharacter model =
    String.length model.restOfCharacters == 0


isStringWhitespace : String -> Bool
isStringWhitespace string =
    -- empty string is not whitespace
    if String.length string == 0 then
        False

    else if (String.trim string |> String.length) == 0 then
        True

    else
        False


dropOneCharacter : Model -> Model
dropOneCharacter model =
    { model
        | firstCharacter = String.left 1 model.restOfCharacters
        , restOfCharacters = String.dropLeft 1 model.restOfCharacters
    }


isEndOfName : Model -> Bool
isEndOfName model =
    if
        isWhitespace model
            || isStartOfClass model
            || isStartOfId model
            || isStartOfHtmlAttribute model
            || isEndingTag model
    then
        True

    else
        False


processName : Model -> Model
processName model =
    let
        currentElement =
            model.labelElement

        newElement =
            { currentElement
                | name = model.labelElement.name ++ model.firstCharacter
            }

        newModel =
            dropOneCharacter
                { model
                    | labelElement =
                        newElement
                }
    in
    if isEndOfName model then
        processLabelStep model

    else if isLastCharacter model then
        processLabelStep newModel

    else
        processName newModel


isEndOfId : Model -> Bool
isEndOfId model =
    if
        isWhitespace model
            || isStartOfClass model
            || isStartOfId model
            || isStartOfHtmlAttribute model
            || isEndingTag model
    then
        True

    else
        False


processId : Model -> Model
processId model =
    let
        currentElement =
            model.labelElement

        newElement =
            { currentElement
                | id = model.labelElement.id ++ model.firstCharacter
            }

        newModel =
            dropOneCharacter
                { model
                    | labelElement =
                        newElement
                }
    in
    if isEndOfId model then
        processLabelStep model

    else if isLastCharacter model then
        processLabelStep newModel

    else
        processId newModel


isEndOfClass : Model -> Bool
isEndOfClass model =
    if
        isWhitespace model
            || isStartOfClass model
            || isStartOfId model
            || isStartOfHtmlAttribute model
            || isEndingTag model
    then
        True

    else
        False


processClass : Model -> Bool -> Model
processClass model isfirstCharacterOfClass =
    let
        prefix =
            if isfirstCharacterOfClass && String.length model.labelElement.classes > 0 then
                " "

            else
                ""

        currentElement =
            model.labelElement

        newElement =
            { currentElement
                | classes =
                    model.labelElement.classes
                        ++ prefix
                        ++ model.firstCharacter
            }

        newModel =
            dropOneCharacter
                { model
                    | labelElement =
                        newElement
                }
    in
    if isEndOfId model then
        processLabelStep model

    else if isLastCharacter model then
        processLabelStep newModel

    else
        processClass newModel False


processEndingTag : Model -> Model
processEndingTag model =
    let
        currentElement =
            model.labelElement

        newElement =
            { currentElement
                | endingTag =
                    False
            }

        newModel =
            { model
                | labelElement =
                    newElement
            }
    in
    processLabelStep newModel


isStartOfHtmlAttribute : Model -> Bool
isStartOfHtmlAttribute model =
    if model.firstCharacter == "[" then
        True

    else
        False


isEndOfHtmlAttribute : Model -> Bool
isEndOfHtmlAttribute model =
    if model.firstCharacter == "]" then
        True

    else
        False


processHtmlAttribute : Model -> Model
processHtmlAttribute model =
    let
        currentElement =
            model.labelElement

        newElement =
            { currentElement
                | htmlAttributes =
                    model.labelElement.htmlAttributes
                        ++ model.firstCharacter
            }

        newModel =
            dropOneCharacter
                { model
                    | labelElement =
                        newElement
                }
    in
    if isEndOfHtmlAttribute model then
        processLabelStep (dropOneCharacter model)

    else if isLastCharacter model then
        processLabelStep newModel

    else
        processHtmlAttribute newModel


processLabelStep : Model -> Model
processLabelStep model =
    if String.length model.firstCharacter == 0 then
        finalizeElement model

    else if isWhitespace model then
        processLabelStep
            (dropOneCharacter
                (finalizeElement model)
            )

    else if isStartOfClass model then
        processClass (dropOneCharacter model) True

    else if isStartOfId model then
        processId (dropOneCharacter model)

    else if isStartOfHtmlAttribute model then
        processHtmlAttribute (dropOneCharacter model)

    else if isEndingTag model then
        processEndingTag (dropOneCharacter model)

    else
        processName model


processLabel : String -> List LabelElement
processLabel label =
    let
        model =
            { initialModel
                | firstCharacter = String.left 1 label
                , restOfCharacters = String.dropLeft 1 label
            }
    in
    (processLabelStep model).labelElements


handleElementStart : LabelElement -> String
handleElementStart element =
    case element.name of
        "biu" ->
            "<b><i><u>"

        _ ->
            ""


handleElementEnd : LabelElement -> String
handleElementEnd element =
    case element.name of
        "biu" ->
            "</u></i></b>"

        _ ->
            ""


labelElementStartingTagToString : LabelElement -> String
labelElementStartingTagToString labelElement =
    let
        id =
            if String.length labelElement.id /= 0 then
                " id=\"" ++ labelElement.id ++ "\""

            else
                ""

        classes =
            if String.length labelElement.classes /= 0 then
                " class=\"" ++ labelElement.classes ++ "\""

            else
                ""

        htmlAttributes =
            if String.length labelElement.htmlAttributes /= 0 then
                " " ++ labelElement.htmlAttributes

            else
                ""

        ending =
            if labelElement.endingTag then
                ">"

            else
                "/>"
    in
    if String.length labelElement.name == 0 then
        ""

    else if hasModule labelElement.name then
        handleElementStart
            labelElement

    else
        "<"
            ++ labelElement.name
            ++ id
            ++ classes
            ++ htmlAttributes
            ++ ending


labelElementEndingTagToString : LabelElement -> String
labelElementEndingTagToString labelElement =
    if labelElement.endingTag == False || String.length labelElement.name == 0 then
        ""

    else if hasModule labelElement.name then
        handleElementEnd
            labelElement

    else
        "</"
            ++ labelElement.name
            ++ ">"



--main =
--    div
--        []
--        ("link[rel='stylesheet' href='style.css']. b[x-m-id='fuck my ass'].hey#now.brown.cow"
--            |> processLabel
--            |> List.map labelElementToHtml
--        )
