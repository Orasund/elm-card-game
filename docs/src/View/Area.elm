module View.Area exposing (..)

import Game.Area
import Game.Entity exposing (Entity)
import Html exposing (Attribute, Html)
import Html.Attributes
import Random
import View.Component


singleCard : Html msg
singleCard =
    [ Game.Entity.new (\attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs)
        |> (\it -> { it | rotation = -pi / 16, position = ( -50, 0 ) })
    ]
        |> Game.Entity.pileAbove (View.Component.empty [])
        |> Game.Entity.toHtml []


below : Html msg
below =
    Game.Entity.new (\attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs)
        |> List.repeat 3
        |> Game.Area.withPolarPosition
            { minDistance = -50
            , maxDistance = 0
            , minAngle = pi / 2
            , maxAngle = pi / 2
            }
        |> Game.Entity.pileAbove (View.Component.empty [])
        |> Game.Entity.toHtml []


rotated : Html msg
rotated =
    Game.Entity.new (\attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs)
        |> List.repeat 3
        |> Game.Area.withLinearRotation { min = -pi / 16, max = 0 }
        |> Game.Entity.pileAbove (View.Component.empty [])
        |> Game.Entity.toHtml []


random : Html msg
random =
    Game.Entity.new (\attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs)
        |> List.repeat 3
        |> Game.Area.mapRotationRandomly (\_ _ _ -> Random.float (-pi / 8) (pi / 8))
        |> Random.andThen
            (Game.Area.mapPositionRandomly
                (\_ _ _ ->
                    Random.map2 (\angle distance -> fromPolar ( distance, angle ))
                        (Random.float (-pi / 8) (pi / 8))
                        (Random.float -50 50)
                )
            )
        |> (\generator -> Random.step generator (Random.initialSeed 40))
        |> Tuple.first
        |> Game.Entity.pileAbove (View.Component.empty [])
        |> Game.Entity.toHtml []


hand : Html msg
hand =
    Game.Entity.new ()
        |> List.repeat 5
        |> Game.Area.withPolarPosition
            { minDistance = -100
            , maxDistance = 100
            , minAngle = -pi / 32
            , maxAngle = pi / 32
            }
        |> Game.Area.withLinearRotation { min = -pi / 16, max = pi / 16 }
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
        |> List.map (Game.Entity.map (\() attrs -> View.Component.defaultCard |> Game.Entity.toHtml attrs))
        |> Game.Entity.pileAbove (Html.text "")
        |> Game.Entity.toHtml
            [ Html.Attributes.style "height" "250px"
            , Html.Attributes.style "width" "400px"
            , Html.Attributes.style "align-items" "end"
            , Html.Attributes.style "justify-content" "center"
            ]


hoverable : { onEnter : Int -> msg, onLeave : msg, hoverOver : Maybe Int } -> Html msg
hoverable args =
    List.repeat 3 ()
        |> List.indexedMap
            (\i () ->
                [ Game.Entity.flippable []
                    { front = View.Component.defaultCard
                    , back = View.Component.defaultBack
                    , faceUp = args.hoverOver == Just i
                    }
                ]
                    |> Game.Entity.pileAbove
                        (View.Component.empty [])
                    |> Game.Entity.toHtml
                        (Game.Area.hoverable
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
                let
                    attrs =
                        Game.Area.draggable
                            { onPress = args.onPress i
                            , onRelease = args.onRelease i
                            }
                in
                (if args.cardAt == i then
                    ( "draggable__card"
                    , \a -> View.Component.defaultCard |> Game.Entity.toHtml (attrs ++ a)
                    )
                        |> Game.Entity.new
                        |> (\stackItem ->
                                if args.isSelected then
                                    { stackItem | rotation = pi / 16 }

                                else
                                    stackItem
                           )
                        |> List.singleton

                 else
                    []
                )
                    |> Game.Area.pileAbove ( toFloat i * 150, 0 )
                        ( "draggable__empty_" ++ String.fromInt i
                        , \a -> View.Component.empty (attrs ++ a)
                        )
            )
        |> List.concat
        |> Game.Area.toHtml [ Html.Attributes.style "height" "200px" ]
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
    -> List (Entity ( String, List (Attribute msg) -> Html msg ))
pile index args list =
    let
        attrs =
            Game.Area.draggable { onPress = args.onStartDragging, onRelease = args.onStopDragging }
                ++ Game.Area.hoverable { onEnter = args.onEntering, onLeave = args.onEntering }
    in
    list
        |> List.reverse
        |> List.map Game.Entity.new
        |> List.indexedMap
            (\i stackItem ->
                (if stackItem.content.asPhantom then
                    stackItem
                        |> Game.Entity.mapZIndex ((+) 100)

                 else
                    stackItem
                )
                    |> Game.Entity.map
                        (\card ->
                            ( "pile__" ++ String.fromInt card.cardId
                            , \a ->
                                View.Component.defaultCard
                                    |> Game.Entity.toHtml
                                        ((if card.asPhantom then
                                            [ Html.Attributes.style "filter" "brightness(0.9)"
                                            ]

                                          else
                                            []
                                         )
                                            ++ attrs
                                            ++ a
                                        )
                            )
                        )
                    |> Game.Entity.mapPosition
                        (Tuple.mapBoth
                            ((+) 0)
                            ((+) (-4 * toFloat i))
                        )
                    |> Game.Entity.mapRotation
                        ((+)
                            (if stackItem.content.asPhantom then
                                pi / 16

                             else
                                stackItem.rotation
                            )
                        )
            )
        |> Game.Area.pileAbove args.position
            ( "pile__empty__" ++ String.fromInt index
            , \a -> View.Component.empty (Html.Attributes.style "z-index" "0" :: attrs ++ a)
            )
