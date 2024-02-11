module View.Area exposing (..)

import Game.Entity
import Html exposing (Html)
import Html.Attributes
import Html.Keyed
import View.Component


singleCard : Html msg
singleCard =
    [ View.Component.empty [ Game.Entity.asStackItems ]
    , Game.Entity.new
        |> Game.Entity.rotate (-pi / 16)
        |> Game.Entity.move ( -50, 0 )
        |> Game.Entity.toAttributes
        |> (++) [ Game.Entity.asStackItems ]
        |> View.Component.defaultCard
    ]
        |> Html.div [ Game.Entity.asStack ]


below : Html msg
below =
    List.repeat 3 ()
        |> List.indexedMap
            (\i () ->
                Game.Entity.new
                    |> Game.Entity.moveEvenlyAroundCenter
                        { minDistance = -50
                        , maxDistance = 0
                        , minAngle = pi / 2
                        , maxAngle = pi / 2
                        , index = i
                        , length = 3
                        }
                    |> Game.Entity.toAttributes
                    |> (::) Game.Entity.asStackItems
                    |> View.Component.defaultCard
            )
        |> Html.div [ Game.Entity.asStack ]


rotated : Html msg
rotated =
    List.repeat 3 ()
        |> List.indexedMap
            (\i () ->
                Game.Entity.new
                    |> Game.Entity.rotateEvenly
                        { min = -pi / 16
                        , max = 0
                        , length = 3
                        , index = i
                        }
                    |> Game.Entity.toAttributes
                    |> (::) Game.Entity.asStackItems
                    |> View.Component.defaultCard
            )
        |> List.map
            (\entity ->
                entity
            )
        |> Html.div [ Game.Entity.asStack ]


hand : Html msg
hand =
    List.repeat 5 ()
        |> List.indexedMap
            (\i () ->
                Game.Entity.new
                    |> Game.Entity.moveEvenlyAroundCenter
                        { minDistance = -100
                        , maxDistance = 100
                        , minAngle = -pi / 32
                        , maxAngle = pi / 32
                        , length = 5
                        , index = i
                        }
                    |> (if i == 3 then
                            Game.Entity.move ( 0, -50 )

                        else
                            Game.Entity.rotateEvenly
                                { min = -pi / 16
                                , max = pi / 16
                                , length = 5
                                , index = i
                                }
                       )
                    |> Game.Entity.toAttributes
                    |> (::) Game.Entity.asStackItems
                    |> View.Component.defaultCard
            )
        |> Html.div
            [ Html.Attributes.style "height" "250px"
            , Html.Attributes.style "width" "400px"
            , Html.Attributes.style "align-items" "end"
            , Html.Attributes.style "justify-content" "center"
            , Game.Entity.asStack
            ]


hoverable : { onEnter : Int -> msg, onLeave : msg, hoverOver : Maybe Int } -> Html msg
hoverable args =
    List.repeat 3 ()
        |> List.indexedMap
            (\i () ->
                [ View.Component.empty [ Game.Entity.asStackItems ]
                , Game.Entity.flippable []
                    { front = View.Component.defaultCard
                    , back = View.Component.defaultBack
                    , faceUp = args.hoverOver == Just i
                    }
                    Game.Entity.new
                ]
                    |> Html.div
                        (Game.Entity.asStack
                            :: Game.Entity.hoverable
                                { onEnter = Just (args.onEnter i), onLeave = Just args.onLeave }
                        )
            )
        |> Html.div
            [ Html.Attributes.style "display" "flex"
            , Html.Attributes.style "flex-direction" "row"
            , Html.Attributes.style "flex-wrap" "wrap"
            , Html.Attributes.style "gap" "8px"
            , Game.Entity.perspective
            ]


draggable : { onPress : Int -> Maybe msg, onRelease : Int -> Maybe msg, cardAt : Int, isSelected : Bool } -> Html msg
draggable args =
    List.repeat 3 ()
        |> List.indexedMap
            (\i () ->
                (if args.cardAt == i then
                    [ Game.Entity.new
                        |> (if args.isSelected then
                                Game.Entity.rotate (pi / 16)

                            else
                                identity
                           )
                        |> Game.Entity.move ( toFloat i * 150, 0 )
                        |> Game.Entity.toAttributes
                    , Game.Entity.draggable
                        { onPress = args.onPress i
                        , onRelease = args.onRelease i
                        }
                    , [ Game.Entity.asStackItems ]
                    ]
                        |> List.concat
                        |> View.Component.defaultCard
                        |> Tuple.pair "draggable__card"
                        |> List.singleton

                 else
                    []
                )
                    |> (::)
                        (Game.Entity.new
                            |> Game.Entity.move ( toFloat i * 150, 0 )
                            |> Game.Entity.toAttributes
                            |> (::) Game.Entity.asStackItems
                            |> View.Component.empty
                            |> Tuple.pair ("draggable__empty_" ++ String.fromInt i)
                        )
            )
        |> List.concat
        |> Html.Keyed.node "div" [ Game.Entity.asStack, Html.Attributes.style "height" "200px" ]
        |> List.singleton
        |> Html.div [ Game.Entity.perspective ]


pile :
    Int
    ->
        { position : ( Float, Float )
        , onStartDragging : Maybe msg
        , onStopDragging : Maybe msg
        , onEntering : Maybe msg
        , onLeaving : Maybe msg
        }
    -> List { cardId : Int, card : card, asPhantom : Bool }
    -> Html msg
pile index args list =
    let
        attrs =
            Game.Entity.draggable { onPress = args.onStartDragging, onRelease = args.onStopDragging }
                ++ Game.Entity.hoverable { onEnter = args.onEntering, onLeave = args.onEntering }
    in
    list
        |> List.reverse
        |> List.indexedMap
            (\i content ->
                Game.Entity.new
                    |> (if content.asPhantom then
                            Game.Entity.mapZIndex ((+) 100)

                        else
                            identity
                       )
                    |> Game.Entity.move ( 0, -4 * toFloat i )
                    |> (if content.asPhantom then
                            Game.Entity.rotate (pi / 16)

                        else
                            identity
                       )
                    |> Game.Entity.toAttributes
                    |> (++)
                        (if content.asPhantom then
                            [ Html.Attributes.style "filter" "brightness(0.9)"
                            ]

                         else
                            []
                        )
                    |> View.Component.defaultCard
                    |> Tuple.pair ("pile__" ++ String.fromInt content.cardId)
            )
        |> (::)
            (Game.Entity.new
                |> Game.Entity.move args.position
                |> Game.Entity.toAttributes
                |> (++) [ Html.Attributes.style "z-index" "0" ]
                |> (++) attrs
                |> View.Component.empty
                |> Tuple.pair ("pile__empty__" ++ String.fromInt index)
            )
        |> Html.Keyed.node "div" [ Game.Entity.asStack ]
