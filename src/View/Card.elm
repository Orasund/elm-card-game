module View.Card exposing (..)

import Game.Card
import Game.Entity
import Html exposing (Html)
import View.Component


empty : Html msg
empty =
    View.Component.empty []


back : Html msg
back =
    Html.text "Title" |> Game.Card.back []


default : Html msg
default =
    Html.text "Title"
        |> Game.Card.element []
        |> List.singleton
        |> Game.Card.default []


square : Html msg
square =
    Html.text "Title"
        |> Game.Card.element []
        |> List.singleton
        |> Game.Card.default [ Game.Card.ratio 1 ]


horizontal : Html msg
horizontal =
    Html.text "Title"
        |> Game.Card.element []
        |> List.singleton
        |> Game.Card.default [ Game.Card.ratio 1.5 ]


element : Html msg
element =
    [ Html.text "This is an element of the card. It has a 8px wide border and wraps the content to fit into the element."
        |> Game.Card.element []
    ]
        |> Game.Card.default []


backgroundImage : Html msg
backgroundImage =
    [ Html.text "Title"
        |> Game.Card.element []
    ]
        |> Game.Card.default (Game.Card.backgroundImage View.Component.image)


row : Html msg
row =
    [ Html.text "Title" |> Game.Card.element []
    , Html.text "🔥" |> Game.Card.element []
    ]
        |> Game.Card.row []
        |> List.singleton
        |> Game.Card.default []


fullImage : Html msg
fullImage =
    [ Html.text "Title"
        |> Game.Card.element []
    , View.Component.image |> Game.Card.fillingImage []
    ]
        |> Game.Card.default []


rotated : Html msg
rotated =
    View.Component.defaultCard
        |> Game.Entity.mapRotation ((+) (pi / 2))
        |> Game.Entity.toHtml []


small : Html msg
small =
    View.Component.defaultCard
        |> Game.Entity.mapCustomTransformations ((++) [ Game.Entity.scale (1 / 2) ])
        |> Game.Entity.toHtml []


move : Html msg
move =
    View.Component.defaultCard
        |> Game.Entity.mapPosition (\_ -> ( 0, -50 ))
        |> Game.Entity.toHtml []


flipped : Html msg
flipped =
    View.Component.defaultCard
        |> Game.Entity.mapCustomTransformations ((++) [ Game.Entity.flip (pi / 4) ])
        |> Game.Entity.toHtml []
        |> List.singleton
        |> Html.div [ Game.Entity.perspective ]


coin : Html msg
coin =
    Html.text "Title" |> Game.Card.coin []
