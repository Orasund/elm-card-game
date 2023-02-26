module View.Entity exposing (..)

import Game.Card
import Game.Entity
import Html exposing (Html)
import View.Component


move : Html msg
move =
    [ (\attrs ->
        Html.text "Title"
            |> Game.Card.element
                attrs
      )
        |> Game.Entity.new
        |> Game.Entity.move ( 90, 160 )
        |> Game.Entity.toHtml []
    ]
        |> Game.Card.default (Game.Card.backgroundImage View.Component.image)


rotate : Html msg
rotate =
    [ [ (\attrs ->
            Html.text "Title"
                |> Game.Card.element
                    attrs
        )
            |> Game.Entity.new
            |> Game.Entity.rotate (-pi / 4)
            |> Game.Entity.toHtml []
      ]
        |> Game.Card.row []
    ]
        |> Game.Card.default (Game.Card.backgroundImage View.Component.image)


mapRotation : Html msg
mapRotation =
    View.Component.defaultCard
        |> Game.Entity.mapRotation ((+) (pi / 2))
        |> Game.Entity.toHtml []


scale : Html msg
scale =
    View.Component.defaultCard
        |> Game.Entity.mapCustomTransformations ((++) [ Game.Entity.scale (1 / 2) ])
        |> Game.Entity.toHtml []


mapPosition : Html msg
mapPosition =
    View.Component.defaultCard
        |> Game.Entity.mapPosition (\_ -> ( 0, -50 ))
        |> Game.Entity.toHtml []


flip : Html msg
flip =
    View.Component.defaultCard
        |> Game.Entity.mapCustomTransformations ((++) [ Game.Entity.flipTransformation (pi / 4) ])
        |> Game.Entity.toHtml []
        |> List.singleton
        |> Html.div [ Game.Entity.perspective ]
