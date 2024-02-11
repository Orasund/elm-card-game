module Example.FlippableCard exposing (..)

import Game.Entity
import Html exposing (Html)
import Html.Events
import View.Component


type alias Model =
    { isFlipped : Bool }


type Msg
    = Flip


init : Model
init =
    { isFlipped = False }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Flip ->
            { model | isFlipped = not model.isFlipped }


view : Model -> Html Msg
view model =
    Game.Entity.new
        |> Game.Entity.flippable [ Html.Events.onClick Flip ]
            { front = View.Component.defaultCard
            , back = View.Component.defaultBack
            , faceUp = model.isFlipped
            }
        |> List.singleton
        |> Html.div [ Game.Entity.perspective ]
