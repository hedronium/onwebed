module Types exposing (Box(..), BoxAttribute, BoxType(..), DocumentStatus(..), FlagType, KeyInteractionType(..), LPModel, LabelElement, MenuItem, Model, Msg(..))

-- label processor model


type alias LPModel =
    { firstCharacter : String
    , restOfCharacters : String
    , labelElement : LabelElement
    , labelElements : List LabelElement
    }


type alias LabelElement =
    { name : String
    , classes : String
    , id : String
    , htmlAttributes : String
    , endingTag : Bool
    }



-- Box type


type Box
    = Box
        { id : Int
        , label : Maybe String
        , labelElements : List LabelElement
        , content : Maybe String
        , parent : Int
        , type_ : BoxType
        }



-- Box type's type


type BoxType
    = SolidBox
    | LiquidBox



-- box attribute


type alias BoxAttribute =
    { name : String
    , value : String
    }



-- message


type Msg
    = AddBoxInside Box Int
    | SetLabel Int (Maybe String)
    | KeyInteraction KeyInteractionType String Bool
    | SolidBoxAdditionBefore Int
    | LiquidBoxAdditionBefore Int
    | SolidBoxAdditionAfter Int
    | LiquidBoxAdditionAfter Int
    | SolidBoxAdditionInsideFirst Int
    | LiquidBoxAdditionInsideFirst Int
    | SolidBoxAdditionInsideLast Int
    | LiquidBoxAdditionInsideLast Int
    | SelectBox Int
    | LabelUpdate Int String
    | LiquidBoxUpdate Int String
    | MenuItemClicked String
    | RemoveLabel Int
    | AddLabel Int
    | RemoveBox Int
    | ResetExport
    | ResetImport
    | PageNameChanged String
    | PageTitleChanged String
    | Import
    | SetImport String
    | AdjustHeight Int
    | Expand
    | DuplicateBoxSelectBox Int
    | DuplicateBoxBefore Int
    | DuplicateBoxInsideFirst Int
    | DuplicateBoxInsideLast Int
    | DuplicateBoxAfter Int
    | MoveBoxSelectBox Int


type KeyInteractionType
    = Up
    | Down
    | Press



-- model


type alias Model =
    { document : List Box
    , menu : List MenuItem
    , status : DocumentStatus
    , menuMessage : Maybe String
    , selectedBoxId : Int
    , export : String
    , pageName : String
    , pageTitle : String
    , import_ : Bool
    , importString : String
    , csrfToken : String
    , documentValidity : Int
    , duplicateSubjectId : Maybe Int
    }


type DocumentStatus
    = Default
    | SolidBoxAdditionShowOptions
    | LiquidBoxAdditionShowOptions
    | SolidBoxAdditionBeforeChooseBox
    | LiquidBoxAdditionBeforeChooseBox
    | SolidBoxAdditionAfterChooseBox
    | LiquidBoxAdditionAfterChooseBox
    | SolidBoxAdditionInsideFirstChooseBox
    | LiquidBoxAdditionInsideFirstChooseBox
    | SolidBoxAdditionInsideLastChooseBox
    | LiquidBoxAdditionInsideLastChooseBox
    | RemoveLabelChooseBox
    | AddLabelChooseBox
    | RemoveBoxChooseBox
    | DuplicateBoxChooseBox
    | DuplicateBoxShowOptions
    | DuplicateBoxBeforeChooseBox
    | DuplicateBoxInsideFirstChooseBox
    | DuplicateBoxInsideLastChooseBox
    | DuplicateBoxAfterChooseBox
    | MoveBoxChooseBox


type alias MenuItem =
    { name : String
    , machineName : String
    }


type alias FlagType =
    { pageName : String
    , pageTitle : String
    , content : String
    , csrfToken : String
    }
