port module Main exposing (main)

import Browser exposing (..)
import State exposing (initialModel, subscriptions, update)
import View exposing (view)


main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
