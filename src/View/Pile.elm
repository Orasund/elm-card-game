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
        |> Game.Pile.withMovement
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
        |> Game.Pile.withRotation { min = -pi / 16, max = 0 }
        |> Game.Pile.toHtml []
            { view = \_ () attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs identity
            , empty = View.Component.empty []
            }


random : Html msg
random =
    ()
        |> List.repeat 3
        |> Game.Pile.generate
            (Random.map2
                (\rotationFun moveFun a b ->
                    { rotation = (rotationFun a b).rotation
                    , movement = (moveFun a b).movement
                    }
                )
                (Game.Pile.randomRotation { min = -pi / 8, max = pi / 8 })
                (Game.Pile.randomMovement { minAngle = -pi / 8, maxAngle = pi / 8, minDistance = -50, maxDistance = 50 })
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
        |> Game.Pile.withMovement
            { minDistance = -100
            , maxDistance = 100
            , minAngle = -pi / 32
            , maxAngle = pi / 32
            }
        |> Game.Pile.withRotation { min = -pi / 16, max = pi / 16 }
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
