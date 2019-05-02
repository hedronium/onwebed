port module State exposing (initialModel, subscriptions, update)

import Box exposing (..)
import Browser.Events exposing (..)
import Json.Decode as Decode exposing (..)
import Menu exposing (..)
import Odl exposing (..)
import Rest exposing (..)
import Types exposing (..)


port expandElements : () -> Cmd msg



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onKeyDown (Decode.map2 (KeyInteraction Down) keyDecoder shiftKeyDecoder)
        ]



-- initial model


initialModel : FlagType -> ( Model, Cmd Msg )
initialModel flags =
    ( { document =
            jsonStringToDocument flags.content
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
      , export = ""
      , pageName = flags.pageName
      , pageTitle = flags.pageTitle
      , import_ = False
      , odlString = ""
      , importString = ""
      , csrfToken = flags.csrfToken
      , documentValidity = 0
      , duplicateSubjectId = Nothing
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
                        , status = DuplicateBoxShowOptions
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

        EditBoxSelectBox moveBoxId ->
            let
                newModel =
                    { model
                        | status = EditBox
                    }
            in
            ( newModel, Cmd.none )

        Expand ->
            let
                newModel =
                    documentValidityIncrement model
            in
            ( newModel, expandElements () )

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
                                | status = SolidBoxAdditionShowOptions
                            }

                        else if key == "l" then
                            { model
                                | status = LiquidBoxAdditionShowOptions
                            }

                        else if key == "e" then
                            { model
                                | status = EditBoxChooseBox
                            }

                        else if key == "r" then
                            { model
                                | status = RemoveBoxChooseBox
                            }

                        else if key == "d" then
                            { model
                                | status = DuplicateBoxChooseBox
                            }

                        else
                            model

                    else if model.status == SolidBoxAdditionShowOptions then
                        if key == "a" then
                            { model
                                | status = SolidBoxAdditionBeforeChooseBox
                            }

                        else if key == "d" then
                            { model
                                | status = SolidBoxAdditionAfterChooseBox
                            }

                        else if key == "w" then
                            { model
                                | status = SolidBoxAdditionInsideFirstChooseBox
                            }

                        else if key == "s" then
                            { model
                                | status = SolidBoxAdditionInsideLastChooseBox
                            }

                        else
                            model

                    else if model.status == LiquidBoxAdditionShowOptions then
                        if key == "a" then
                            { model
                                | status = LiquidBoxAdditionBeforeChooseBox
                            }

                        else if key == "d" then
                            { model
                                | status = LiquidBoxAdditionAfterChooseBox
                            }

                        else if key == "w" then
                            { model
                                | status = LiquidBoxAdditionInsideFirstChooseBox
                            }

                        else if key == "s" then
                            { model
                                | status = LiquidBoxAdditionInsideLastChooseBox
                            }

                        else
                            model

                    else if key == "Escape" then
                        { model
                            | status = Default
                            , import_ = False
                            , export = ""
                            , selectedBoxId = 0
                        }

                    else
                        model

                --else if key == "a" && model.status == SolidBoxAdditionShowOptions then
                --    { model
                --        | status = SolidBoxAdditionBeforeChooseBox
                --    }
            in
            ( newModel
            , Cmd.none
            )

        SolidBoxAdditionBefore addBeforeBoxId ->
            let
                newModel =
                    insertBoxBefore addBeforeBoxId SolidBox model
            in
            ( newModel
            , expandElements ()
            )

        LiquidBoxAdditionBefore addBeforeLiquidBoxId ->
            let
                newModel =
                    insertBoxBefore addBeforeLiquidBoxId LiquidBox model
            in
            ( newModel
            , expandElements ()
            )

        SolidBoxAdditionAfter addAfterBoxId ->
            let
                newModel =
                    insertBoxAfter addAfterBoxId SolidBox model
            in
            ( newModel
            , expandElements ()
            )

        LiquidBoxAdditionAfter addAfterLiquidBoxId ->
            let
                newModel =
                    insertBoxAfter addAfterLiquidBoxId LiquidBox model
            in
            ( newModel
            , expandElements ()
            )

        SolidBoxAdditionInsideFirst addInsideFirstBoxId ->
            let
                newModel =
                    insertBoxInsideFirst addInsideFirstBoxId SolidBox model
            in
            ( newModel
            , expandElements ()
            )

        LiquidBoxAdditionInsideFirst addInsideFirstLiquidBoxId ->
            let
                newModel =
                    insertBoxInsideFirst addInsideFirstLiquidBoxId LiquidBox model
            in
            ( newModel
            , expandElements ()
            )

        SolidBoxAdditionInsideLast addInsideLastBoxId ->
            let
                newModel =
                    insertBoxInsideLast addInsideLastBoxId SolidBox model
            in
            ( newModel
            , expandElements ()
            )

        LiquidBoxAdditionInsideLast addInsideLastLiquidBoxId ->
            let
                newModel =
                    insertBoxInsideLast addInsideLastLiquidBoxId LiquidBox model
            in
            ( newModel
            , expandElements ()
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
                        | document = List.map (updateBoxLabel boxId label) model.document
                    }
            in
            ( newModel
            , Cmd.none
            )

        LiquidBoxUpdate boxId content ->
            let
                newModel =
                    { model
                        | document = List.map (updateBoxContent boxId content) model.document
                    }
            in
            ( newModel
            , Cmd.none
            )

        RemoveLabel boxId ->
            let
                newModel =
                    documentValidityIncrement
                        { model
                            | document = List.map (removeLabel boxId) model.document
                            , status = Default
                            , selectedBoxId = 0
                        }
            in
            ( newModel
            , expandElements ()
            )

        AddLabel boxId ->
            let
                newModel =
                    documentValidityIncrement
                        { model
                            | document = List.map (addLabel boxId) model.document
                            , status = Default
                            , selectedBoxId = 0
                        }
            in
            ( newModel
            , expandElements ()
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
            , expandElements ()
            )

        ResetExport ->
            let
                newModel =
                    { model
                        | export = ""
                    }
            in
            ( newModel
            , Cmd.none
            )

        PageNameChanged newPageName ->
            let
                newModel =
                    { model
                        | pageName = newPageName
                    }
            in
            ( newModel
            , Cmd.none
            )

        PageTitleChanged newPageTitle ->
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
                        | import_ = False
                    }
            in
            ( newModel
            , Cmd.none
            )

        SetImport importString ->
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
                        , import_ = False
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
                    { model
                        | odlString = odlString
                    }
            in
            ( newModel
            , Cmd.none
            )

        ApplyOdl ->
            let
                odlParserModel =
                    { boxes = []
                    , status = Unresolved
                    , basket = ""
                    , parent = 0
                    , currentBoxes = []
                    , level = 0
                    }

                newModel =
                    { model
                        | document = odlToBoxes model.odlString odlParserModel
                        , status = Default
                    }
            in
            ( newModel
            , Cmd.none
            )

        ViewOdlModal ->
            let
                children =
                    boxesByParentId 0 model

                boxesToOdlStrings =
                    List.map (boxToOdl model 0) children

                odlString =
                    List.foldr
                        (++)
                        ""
                        (List.intersperse "\n\n" boxesToOdlStrings)

                newModel =
                    { model
                        | odlString = odlString
                    }
            in
            ( newModel
            , Cmd.none
            )

        MenuItemClicked machine_name ->
            let
                newModel =
                    case machine_name of
                        "add_solid_box" ->
                            if isDocumentEmpty model then
                                documentValidityIncrement
                                    { model
                                        | document = documentWithOneBox
                                    }

                            else
                                { model
                                    | status = SolidBoxAdditionShowOptions
                                }

                        "add_solid_box_before" ->
                            { model
                                | status = SolidBoxAdditionBeforeChooseBox
                            }

                        "add_solid_box_after" ->
                            { model
                                | status = SolidBoxAdditionAfterChooseBox
                            }

                        "add_solid_box_inside_first" ->
                            { model
                                | status = SolidBoxAdditionInsideFirstChooseBox
                            }

                        "add_solid_box_inside_last" ->
                            { model
                                | status = SolidBoxAdditionInsideLastChooseBox
                            }

                        "add_liquid_box" ->
                            if isDocumentEmpty model then
                                documentValidityIncrement
                                    { model
                                        | document = documentWithOneBox
                                    }

                            else
                                { model
                                    | status = LiquidBoxAdditionShowOptions
                                }

                        "add_liquid_box_before" ->
                            { model
                                | status = LiquidBoxAdditionBeforeChooseBox
                            }

                        "add_liquid_box_after" ->
                            { model
                                | status = LiquidBoxAdditionAfterChooseBox
                            }

                        "add_liquid_box_inside_first" ->
                            { model
                                | status = LiquidBoxAdditionInsideFirstChooseBox
                            }

                        "add_liquid_box_inside_last" ->
                            { model
                                | status = LiquidBoxAdditionInsideLastChooseBox
                            }

                        "remove_label" ->
                            { model
                                | status = RemoveLabelChooseBox
                            }

                        "add_label" ->
                            { model
                                | status = AddLabelChooseBox
                            }

                        "remove_box" ->
                            { model
                                | status = RemoveBoxChooseBox
                            }

                        "export" ->
                            { model
                                | export = documentToJsonString model
                            }

                        "import" ->
                            { model
                                | import_ = True
                            }

                        "duplicate_box" ->
                            { model
                                | status = DuplicateBoxChooseBox
                            }

                        "duplicate_box_before" ->
                            { model
                                | status = DuplicateBoxBeforeChooseBox
                            }

                        "duplicate_box_after" ->
                            { model
                                | status = DuplicateBoxAfterChooseBox
                            }

                        "duplicate_box_inside_first" ->
                            { model
                                | status = DuplicateBoxInsideFirstChooseBox
                            }

                        "duplicate_box_inside_last" ->
                            { model
                                | status = DuplicateBoxInsideLastChooseBox
                            }

                        "move_box" ->
                            { model
                                | status = MoveBoxChooseBox
                            }

                        "edit_box" ->
                            { model
                                | status = EditBoxChooseBox
                            }

                        "view_odl" ->
                            let
                                children =
                                    boxesByParentId 0 model

                                boxesToOdlStrings =
                                    List.map (boxToOdl model 0) children

                                odlString =
                                    List.foldr
                                        (++)
                                        ""
                                        (List.intersperse "\n\n" boxesToOdlStrings)
                            in
                            { model
                                | status = ViewOdl
                                , odlString = odlString
                            }

                        _ ->
                            model
            in
            ( newModel
            , expandElements ()
            )
