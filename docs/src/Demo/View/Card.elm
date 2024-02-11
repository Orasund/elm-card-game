module Demo.View.Card exposing (..)

import Demo.Card exposing (Card(..))
import Game.Card
import Game.Entity exposing (Entity)
import Html exposing (Attribute, Html)
import Html.Attributes
import View.Component


toEmoji : Card -> String
toEmoji card =
    case card of
        Rock ->
            "🪨"

        Paper ->
            "📄"

        Scissors ->
            "✂️"


toString : Card -> String
toString card =
    case card of
        Rock ->
            "Rock"

        Paper ->
            "Paper"

        Scissors ->
            "Scissors"


toEntity : List (Attribute msg) -> Bool -> ( Entity, Card ) -> Html msg
toEntity attrs faceUp ( entity, card ) =
    Game.Entity.flippable attrs
        { front =
            \a ->
                [ toEmoji card
                    ++ " "
                    ++ toString card
                    |> Html.text
                    |> Game.Card.element [ Html.Attributes.style "font-size" "18px" ]
                , toEmoji card
                    |> Html.text
                    |> Game.Card.element
                        [ Html.Attributes.style "font-size" "64px"
                        , Html.Attributes.style "justify-content" "center"
                        , Html.Attributes.style "align-items" "center"
                        ]
                ]
                    |> Game.Card.default a
        , back = View.Component.defaultBack
        , faceUp = faceUp
        }
        entity
