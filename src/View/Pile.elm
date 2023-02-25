module View.Pile exposing (..)

import Game.Entity
import Game.Pile
import Html exposing (Html)
import Html.Attributes
import Random
import View.Component


singleCard : Html msg
singleCard =
    [ Game.Entity.new ()
        |> (\it -> { it | rotation = -pi / 16, position = ( -50, 0 ) })
    ]
        |> Game.Pile.toHtml []
            { view = \_ () attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs identity
            , empty = View.Component.empty []
            }


below : Html msg
below =
    Game.Entity.new ()
        |> List.repeat 3
        |> Game.Pile.withPolarPosition
            { minDistance = -50
            , maxDistance = 0
            , minAngle = pi / 2
            , maxAngle = pi / 2
            }
        |> Game.Pile.toHtml []
            { view = \_ () attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs identity
            , empty = View.Component.empty []
            }


rotated : Html msg
rotated =
    Game.Entity.new ()
        |> List.repeat 3
        |> Game.Pile.withLinearRotation { min = -pi / 16, max = 0 }
        |> Game.Pile.toHtml []
            { view = \_ () attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs identity
            , empty = View.Component.empty []
            }


random : Html msg
random =
    Game.Entity.new ()
        |> List.repeat 3
        |> Game.Pile.mapRotationRandomly (\_ _ _ -> Random.float (-pi / 8) (pi / 8))
        |> Random.andThen
            (Game.Pile.mapPositionRandomly
                (\_ _ _ ->
                    Random.map2 (\angle distance -> fromPolar ( distance, angle ))
                        (Random.float (-pi / 8) (pi / 8))
                        (Random.float -50 50)
                )
            )
        |> (\generator -> Random.step generator (Random.initialSeed 40))
        |> Tuple.first
        |> Game.Pile.toHtml []
            { view = \_ () attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs identity
            , empty = View.Component.empty []
            }


hand : Html msg
hand =
    Game.Entity.new ()
        |> List.repeat 5
        |> Game.Pile.withPolarPosition
            { minDistance = -100
            , maxDistance = 100
            , minAngle = -pi / 32
            , maxAngle = pi / 32
            }
        |> Game.Pile.withLinearRotation { min = -pi / 16, max = pi / 16 }
        |> List.indexedMap
            (\i stackItem ->
                if i == 3 then
                    { stackItem
                        | rotation = 0
                        , position =
                            stackItem.position
                                |> Tuple.mapBoth
                                    ((+) 0)
                                    ((+) -50)
                    }

                else
                    stackItem
            )
        |> Game.Pile.toHtml
            [ Html.Attributes.style "height" "250px"
            , Html.Attributes.style "width" "400px"
            , Html.Attributes.style "align-items" "end"
            , Html.Attributes.style "justify-content" "center"
            ]
            { view = \_ () attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs identity
            , empty = Html.text ""
            }
