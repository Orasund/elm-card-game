module View.Entity exposing (..)

import Game.Card
import Game.Entity
import Html exposing (Html)
import View.Component


move : Html msg
move =
    [ Html.text "Title"
        |> Game.Card.element
            (Game.Entity.new
                |> Game.Entity.move ( 90, 160 )
                |> Game.Entity.toAttributes
            )
    ]
        |> Game.Card.default (Game.Card.backgroundImage View.Component.image)


rotate : Html msg
rotate =
    [ [ Html.text "Title"
            |> Game.Card.element
                (Game.Entity.new
                    |> Game.Entity.rotate (-pi / 4)
                    |> Game.Entity.toAttributes
                )
      ]
        |> Game.Card.row []
    ]
        |> Game.Card.default (Game.Card.backgroundImage View.Component.image)


mapRotation : Html msg
mapRotation =
    Game.Entity.new
        |> Game.Entity.mapRotation ((+) (pi / 2))
        |> Game.Entity.toAttributes
        |> View.Component.defaultCard


scale : Html msg
scale =
    Game.Entity.new
        |> Game.Entity.mapCustomTransformations ((++) [ Game.Entity.scale (1 / 2) ])
        |> Game.Entity.toAttributes
        |> View.Component.defaultCard


mapPosition : Html msg
mapPosition =
    Game.Entity.new
        |> Game.Entity.mapPosition (\_ -> ( 0, -50 ))
        |> Game.Entity.toAttributes
        |> View.Component.defaultCard


flip : Html msg
flip =
    Game.Entity.new
        |> Game.Entity.mapCustomTransformations ((++) [ Game.Entity.flipTransformation (pi / 4) ])
        |> Game.Entity.toAttributes
        |> View.Component.defaultCard
        |> List.singleton
        |> Html.div [ Game.Entity.perspective ]
