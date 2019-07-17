module Bulma exposing (toHtml)

import Types exposing (LabelElement)

toHtml : LabelElement -> String
toHtml label =
    "<link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/bulma@0.7.4/css/bulma.min.css'/>"