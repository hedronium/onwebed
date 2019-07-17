port module State exposing (initialModel, subscriptions, update)

import Box exposing (..)
import Browser.Events exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Menu exposing (..)
import Odl exposing (..)
import Rest exposing (..)
import Types exposing (..)


port overlay : Bool -> Cmd msg


port setupTextEditor : String -> Cmd msg


port setOdlString : (String -> msg) -> Sub msg



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onKeyDown (Decode.map2 (KeyInteraction Down) keyDecoder shiftKeyDecoder)
        , setOdlString SetOdlString
        ]



-- initial model


initialModel : FlagType -> ( Model, Cmd Msg )
initialModel flags =
    ( { document =
            jsonStringToDocument flags.content
      , documentDraft = []
      , status = Default
      , menu =
            [ menuItem "+ solid box" "add_solid_box"
            , menuItem "+ liquid box" "add_liquid_box"
            , menuItem "edit box" "edit_box"
            , menuItem "duplicate box" "duplicate_box"

            --, menuItem "move box" "move_box"
            , menuItem "- box" "remove_box"
            , menuItem "import" "import"
            , menuItem "export" "export"
            , menuItem "view ODL" "view_odl"
            ]
      , menuMessage = Nothing
      , selectedBoxId = 0
      , pageName = flags.pageName
      , pageTitle = flags.pageTitle
      , odlString = ""
      , importString = ""
      , csrfToken = flags.csrfToken
      , duplicateSubjectId = Nothing
      , odlStringInsideBox = ""
      , unsavedDraft = False
      }
    , Cmd.none
    )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DuplicateBoxSelectBox duplicateSubjectId ->
            let
                newModel =
                    { model
                        | duplicateSubjectId = Just duplicateSubjectId
                        , status = DuplicateBoxOptions
                        , selectedBoxId = 0
                    }
            in
            ( newModel, Cmd.none )

        DuplicateBoxBefore duplicateBeforeId ->
            let
                newModel =
                    duplicateBoxBefore
                        duplicateBeforeId
                        { model
                            | status = Default
                            , selectedBoxId = 0
                        }
            in
            ( newModel, Cmd.none )

        DuplicateBoxInsideFirst duplicateInsideFirstId ->
            let
                newModel =
                    duplicateBoxInsideFirst
                        duplicateInsideFirstId
                        { model
                            | status = Default
                            , selectedBoxId = 0
                        }
            in
            ( newModel, Cmd.none )

        DuplicateBoxInsideLast duplicateInsideLastId ->
            let
                newModel =
                    duplicateBoxInsideLast
                        duplicateInsideLastId
                        { model
                            | status = Default
                            , selectedBoxId = 0
                        }
            in
            ( newModel, Cmd.none )

        DuplicateBoxAfter duplicateAfterId ->
            let
                newModel =
                    duplicateBoxAfter
                        duplicateAfterId
                        { model
                            | status = Default
                            , selectedBoxId = 0
                        }
            in
            ( newModel, Cmd.none )

        MoveBoxSelectBox moveBoxId ->
            let
                newModel =
                    { model
                        | status = Default
                        , selectedBoxId = 0
                    }
            in
            ( newModel, Cmd.none )

        EditBoxSelectBox editBoxId ->
            let
                box =
                    boxById editBoxId model

                newModel =
                    case box of
                        Just (Box justBox) ->
                            { model
                                | status = EditBoxModal
                                , odlStringInsideBox = boxContentToOdl (Box justBox) model 0
                                , documentDraft = model.document
                                , selectedBoxId = editBoxId
                            }

                        Nothing ->
                            model

                additionalCommands =
                    case box of
                        Just (Box justBox) ->
                            if justBox.type_ == SolidBox then
                                [ setupTextEditor newModel.odlStringInsideBox ]

                            else
                                []

                        Nothing ->
                            []
            in
            ( newModel
            , Cmd.batch
                ([ overlay True ]
                    ++ additionalCommands
                )
            )

        -- Add box inside another box
        AdjustHeight height ->
            let
                newModel =
                    { model
                        | importString = String.fromInt height
                    }
            in
            ( newModel, Cmd.none )

        AddBoxInside box targetId ->
            ( model, Cmd.none )

        SetLabel boxId newLabel ->
            let
                newModel =
                    { model
                        | document = boxSetLabel boxId newLabel model.document
                    }
            in
            ( newModel
            , Cmd.none
            )

        KeyInteraction keyInteractionType key shiftPressed ->
            let
                newModel =
                    if model.status == Default then
                        if key == "s" then
                            { model
                                | status = SolidBoxAdditionOptions
                            }

                        else if key == "l" then
                            { model
                                | status = LiquidBoxAdditionOptions
                            }

                        else if key == "e" then
                            { model
                                | status = EditBoxBoxSelection
                            }

                        else if key == "x" then
                            { model
                                | status = RemoveBoxBoxSelection
                            }

                        else if key == "d" then
                            { model
                                | status = DuplicateBoxBoxSelection
                            }

                        else
                            model

                    else if key == "Escape" then
                        if model.status == EditBoxModal then
                            if model.document == model.documentDraft && model.unsavedDraft == False then
                                { model
                                    | status = Default
                                    , selectedBoxId = 0
                                }

                            else
                                { model
                                    | status = EditBoxUnsavedDraftWarning
                                }

                        else if model.status == ViewOdlModal then
                            let
                                originalOdlString =
                                    odlStringOfDocument model
                            in
                            if model.odlString == originalOdlString then
                                { model
                                    | status = Default
                                    , selectedBoxId = 0
                                }

                            else
                                { model
                                    | status = ViewOdlUnsavedDraftWarning
                                }

                        else if model.status == EditBoxUnsavedDraftWarning then
                            { model
                                | status = Default
                                , documentDraft = []
                                , selectedBoxId = 0
                                , unsavedDraft = False
                            }

                        else
                            { model
                                | status = Default
                                , selectedBoxId = 0
                            }

                    else if model.status == SolidBoxAdditionOptions then
                        if key == "a" then
                            { model
                                | status = SolidBoxAdditionBeforeBoxSelection
                            }

                        else if key == "d" then
                            { model
                                | status = SolidBoxAdditionAfterBoxSelection
                            }

                        else if key == "w" then
                            { model
                                | status = SolidBoxAdditionInsideFirstBoxSelection
                            }

                        else if key == "s" then
                            { model
                                | status = SolidBoxAdditionInsideLastBoxSelection
                            }

                        else
                            model

                    else if model.status == LiquidBoxAdditionOptions then
                        if key == "a" then
                            { model
                                | status = LiquidBoxAdditionBeforeBoxSelection
                            }

                        else if key == "d" then
                            { model
                                | status = LiquidBoxAdditionAfterBoxSelection
                            }

                        else if key == "w" then
                            { model
                                | status = LiquidBoxAdditionInsideFirstBoxSelection
                            }

                        else if key == "s" then
                            { model
                                | status = LiquidBoxAdditionInsideLastBoxSelection
                            }

                        else
                            model

                    else
                        model

                command =
                    if key == "Escape" && newModel.status == Default then
                        overlay False

                    else
                        Cmd.none
            in
            ( newModel
            , command
            )

        SolidBoxAdditionBefore addBeforeBoxId ->
            let
                newModel =
                    insertBoxBefore addBeforeBoxId SolidBox model
            in
            ( newModel
            , Cmd.none
            )

        LiquidBoxAdditionBefore addBeforeLiquidBoxId ->
            let
                newModel =
                    insertBoxBefore addBeforeLiquidBoxId LiquidBox model
            in
            ( newModel
            , Cmd.none
            )

        SolidBoxAdditionAfter addAfterBoxId ->
            let
                newModel =
                    insertBoxAfter addAfterBoxId SolidBox model
            in
            ( newModel
            , Cmd.none
            )

        LiquidBoxAdditionAfter addAfterLiquidBoxId ->
            let
                newModel =
                    insertBoxAfter addAfterLiquidBoxId LiquidBox model
            in
            ( newModel
            , Cmd.none
            )

        SolidBoxAdditionInsideFirst addInsideFirstBoxId ->
            let
                newModel =
                    insertBoxInsideFirst addInsideFirstBoxId SolidBox model
            in
            ( newModel
            , Cmd.none
            )

        LiquidBoxAdditionInsideFirst addInsideFirstLiquidBoxId ->
            let
                newModel =
                    insertBoxInsideFirst addInsideFirstLiquidBoxId LiquidBox model
            in
            ( newModel
            , Cmd.none
            )

        SolidBoxAdditionInsideLast addInsideLastBoxId ->
            let
                newModel =
                    insertBoxInsideLast addInsideLastBoxId SolidBox model
            in
            ( newModel
            , Cmd.none
            )

        LiquidBoxAdditionInsideLast addInsideLastLiquidBoxId ->
            let
                newModel =
                    insertBoxInsideLast addInsideLastLiquidBoxId LiquidBox model
            in
            ( newModel
            , Cmd.none
            )

        SelectBox boxToBeSelectedId ->
            let
                newModel =
                    { model
                        | selectedBoxId = boxToBeSelectedId
                    }
            in
            ( newModel
            , Cmd.none
            )

        LabelUpdate boxId label ->
            let
                newModel =
                    { model
                        | documentDraft = List.map (updateBoxLabel boxId label) model.documentDraft
                    }

                newModel2 =
                    if newModel.status == EditBoxUnsavedDraftWarning then
                        { newModel
                            | status = EditBoxModal
                        }

                    else
                        newModel
            in
            ( newModel2
            , Cmd.none
            )

        LiquidBoxUpdate boxId content ->
            let
                newModel =
                    { model
                        | documentDraft = List.map (updateBoxContent boxId content) model.documentDraft
                    }

                newModel2 =
                    if newModel.status == EditBoxUnsavedDraftWarning then
                        { newModel
                            | status = EditBoxModal
                        }

                    else
                        newModel
            in
            ( newModel2
            , Cmd.none
            )

        RemoveBox boxId ->
            let
                newModel =
                    { model
                        | document = removeBox boxId model
                        , status = Default
                        , selectedBoxId = 0
                    }
            in
            ( newModel
            , Cmd.none
            )

        ResetExport ->
            let
                newModel =
                    { model
                        | status = Default
                    }
            in
            ( newModel
            , Cmd.none
            )

        PageNameChange newPageName ->
            let
                newModel =
                    { model
                        | pageName = newPageName
                    }
            in
            ( newModel
            , Cmd.none
            )

        PageTitleChange newPageTitle ->
            let
                newModel =
                    { model
                        | pageTitle = newPageTitle
                    }
            in
            ( newModel
            , Cmd.none
            )

        ResetImport ->
            let
                newModel =
                    { model
                        | status = Default
                    }
            in
            ( newModel
            , Cmd.none
            )

        SetImportString importString ->
            let
                newModel =
                    { model
                        | importString = importString
                    }
            in
            ( newModel
            , Cmd.none
            )

        Import ->
            let
                newModel =
                    { model
                        | document = jsonStringToDocument model.importString
                        , status = Default
                    }
            in
            ( newModel
            , Cmd.none
            )

        ResetOdlModal ->
            let
                newModel =
                    { model
                        | odlString = ""
                        , status = Default
                    }
            in
            ( newModel
            , Cmd.none
            )

        SetOdlString odlString ->
            let
                newModel =
                    if model.status == EditBoxModal then
                        { model
                            | odlStringInsideBox = odlString
                            , unsavedDraft = True
                        }

                    else if model.status == EditBoxUnsavedDraftWarning then
                        { model
                            | odlStringInsideBox = odlString
                            , status = EditBoxModal
                        }

                    else if model.status == ViewOdlUnsavedDraftWarning then
                        { model
                            | odlString = odlString
                            , status = ViewOdlModal
                        }

                    else
                        { model
                            | odlString = odlString
                        }
            in
            ( newModel
            , Cmd.none
            )

        ApplyOdl ->
            let
                newModel =
                    { model
                        | document = odlToBoxes model.odlString initialOdlParserModel
                        , status = Default
                    }
            in
            ( newModel
            , overlay False
            )

        ApplyOdlInsideBox boxId ->
            let
                newModel =
                    if List.length model.documentDraft == 0 then
                        model

                    else
                        { model
                            | document = model.documentDraft
                        }

                boxesFromOdlString =
                    odlToBoxes
                        newModel.odlStringInsideBox
                        initialOdlParserModel

                idOffset =
                    Maybe.withDefault -1 (highestBoxId newModel.document) + 1

                boxesFromOdlStringWithOffsetIds =
                    List.map
                        (\(Box box) ->
                            Box
                                { box
                                    | id = box.id + idOffset
                                    , parent = box.parent + idOffset
                                }
                        )
                        boxesFromOdlString

                boxesWithUpdatedParents =
                    List.map
                        (\(Box box) ->
                            if box.parent == idOffset then
                                Box
                                    { box
                                        | parent = boxId
                                    }

                            else
                                Box box
                        )
                        boxesFromOdlStringWithOffsetIds

                childrenIds =
                    List.map
                        (\(Box box) ->
                            box.id
                        )
                        (boxesByParentId boxId newModel)

                newDocument =
                    removeBoxes childrenIds newModel
                        ++ boxesWithUpdatedParents

                newModel2 =
                    { newModel
                        | document = newDocument
                        , documentDraft = []
                        , status = Default
                        , selectedBoxId = 0
                    }
            in
            ( newModel2
            , overlay False
            )

        MenuItemClick machine_name ->
            let
                newModel =
                    case machine_name of
                        "add_solid_box" ->
                            if isDocumentEmpty model then
                                { model
                                    | document = documentWithOneBox
                                }

                            else
                                { model
                                    | status = SolidBoxAdditionOptions
                                }

                        "add_solid_box_before" ->
                            { model
                                | status = SolidBoxAdditionBeforeBoxSelection
                            }

                        "add_solid_box_after" ->
                            { model
                                | status = SolidBoxAdditionAfterBoxSelection
                            }

                        "add_solid_box_inside_first" ->
                            { model
                                | status = SolidBoxAdditionInsideFirstBoxSelection
                            }

                        "add_solid_box_inside_last" ->
                            { model
                                | status = SolidBoxAdditionInsideLastBoxSelection
                            }

                        "add_liquid_box" ->
                            if isDocumentEmpty model then
                                { model
                                    | document = documentWithOneBox
                                }

                            else
                                { model
                                    | status = LiquidBoxAdditionOptions
                                }

                        "add_liquid_box_before" ->
                            { model
                                | status = LiquidBoxAdditionBeforeBoxSelection
                            }

                        "add_liquid_box_after" ->
                            { model
                                | status = LiquidBoxAdditionAfterBoxSelection
                            }

                        "add_liquid_box_inside_first" ->
                            { model
                                | status = LiquidBoxAdditionInsideFirstBoxSelection
                            }

                        "add_liquid_box_inside_last" ->
                            { model
                                | status = LiquidBoxAdditionInsideLastBoxSelection
                            }

                        "remove_box" ->
                            { model
                                | status = RemoveBoxBoxSelection
                            }

                        "export" ->
                            { model
                                | status = ExportModal
                            }

                        "import" ->
                            { model
                                | status = ImportModal
                            }

                        "duplicate_box" ->
                            { model
                                | status = DuplicateBoxBoxSelection
                            }

                        "duplicate_box_before" ->
                            { model
                                | status = DuplicateBoxBeforeBoxSelection
                            }

                        "duplicate_box_after" ->
                            { model
                                | status = DuplicateBoxAfterBoxSelection
                            }

                        "duplicate_box_inside_first" ->
                            { model
                                | status = DuplicateBoxInsideFirstBoxSelection
                            }

                        "duplicate_box_inside_last" ->
                            { model
                                | status = DuplicateBoxInsideLastBoxSelection
                            }

                        "move_box" ->
                            { model
                                | status = MoveBoxBoxSelection
                            }

                        "edit_box" ->
                            { model
                                | status = EditBoxBoxSelection
                            }

                        "view_odl" ->
                            { model
                                | status = ViewOdlModal
                                , odlString = odlStringOfDocument model
                            }

                        _ ->
                            model

                command =
                    case machine_name of
                        "view_odl" ->
                            let
                                odlString =
                                    odlStringOfDocument model
                            in
                            Cmd.batch
                                [ overlay True
                                , setupTextEditor odlString
                                ]

                        "import" ->
                            overlay True

                        "export" ->
                            overlay True

                        _ ->
                            Cmd.none
            in
            ( newModel
            , command
            )
