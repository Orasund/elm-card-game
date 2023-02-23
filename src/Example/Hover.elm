module Example.Hover exposing (..)

import Html exposing (Html)
import View.Area


type alias Model =
    Maybe Int


init : Model
init =
    Nothing


view : Model -> Html Model
view model =
    View.Area.hoverable
        { onEnter = \int -> Just int
        , onLeave = Nothing
        , hoverOver = model
        }
