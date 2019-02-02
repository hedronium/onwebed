module Rest exposing (keyDecoder, mouseDecoder, shiftKeyDecoder)

import Json.Decode as Decode exposing (..)


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string


shiftKeyDecoder : Decode.Decoder Bool
shiftKeyDecoder =
    Decode.field "shiftKey" Decode.bool


mouseDecoder : Decode.Decoder (Maybe String)
mouseDecoder =
    Decode.field "relatedTarget" (Decode.maybe Decode.string)
