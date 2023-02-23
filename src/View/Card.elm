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
        |> Game.Card.title []
        |> List.singleton
        |> Game.Card.default []


square : Html msg
square =
    Html.text "Title"
        |> Game.Card.title []
        |> List.singleton
        |> Game.Card.default [ Game.Card.ratio 1 ]


horizontal : Html msg
horizontal =
    Html.text "Title"
        |> Game.Card.title []
        |> List.singleton
        |> Game.Card.default [ Game.Card.ratio 1.5 ]


titleRow : Html msg
titleRow =
    [ Html.div [] [ Html.text "Title with a symbol" ]
    , Html.div [] [ Html.text "🔥" ]
    ]
        |> Game.Card.header []
        |> List.singleton
        |> Game.Card.default []


fullImage : Html msg
fullImage =
    [ Html.text "Card with an Image" |> Game.Card.title []
    , View.Component.image |> Game.Card.fillingImage []
    ]
        |> Game.Card.default []


imageAndDesc : Html msg
imageAndDesc =
    [ Html.text "Title" |> Game.Card.title []
    , View.Component.image |> Game.Card.fillingImage []
    , Html.text "Card with image and description"
        |> Game.Card.description []
    ]
        |> Game.Card.default []


rotated : Html msg
rotated =
    View.Component.defaultCard
        |> Game.Entity.withRotation (pi / 2)
        |> Game.Entity.toHtml [] identity


small : Html msg
small =
    View.Component.defaultCard
        |> Game.Entity.withCustomTransformations [ Game.Entity.scale (1 / 2) ]
        |> Game.Entity.toHtml [] identity


move : Html msg
move =
    View.Component.defaultCard
        |> Game.Entity.withPosition ( 0, -50 )
        |> Game.Entity.toHtml [] identity


flipped : Html msg
flipped =
    View.Component.defaultCard
        |> Game.Entity.withCustomTransformations [ Game.Entity.flip (pi / 4) ]
        |> Game.Entity.toHtml [] identity
        |> List.singleton
        |> Html.div [ Game.Entity.perspective ]


coin : Html msg
coin =
    Html.text "Title" |> Game.Card.coin []
