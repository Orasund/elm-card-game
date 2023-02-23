module View.Area exposing (..)

import Game.Area exposing (AreaEntity)
import Game.Card
import Game.Entity
import Game.Pile
import Html exposing (Html)
import Html.Attributes
import View.Component


type alias AreaId =
    { areaId : Int }


type alias CardId =
    { cardId : Int }


hoverable : { onEnter : Int -> msg, onLeave : msg, hoverOver : Maybe Int } -> Html msg
hoverable args =
    List.repeat 3 ()
        |> List.indexedMap
            (\i () ->
                [ Game.Entity.flippable []
                    { front = Game.Entity.new View.Component.defaultCard
                    , back = Game.Entity.new View.Component.defaultBack
                    , faceUp = args.hoverOver == Just i
                    }
                ]
                    |> Game.Pile.toHtml
                        (Game.Area.hoverable
                            { onEnter = Just (args.onEnter i), onLeave = Just args.onLeave }
                        )
                        { view = \_ fun -> fun
                        , empty = View.Component.empty []
                        }
            )
        |> Html.div
            [ Html.Attributes.style "display" "flex"
            , Html.Attributes.style "flex-direction" "row"
            , Html.Attributes.style "flex-wrap" "wrap"
            , Html.Attributes.style "gap" "8px"
            , Game.Card.perspective
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
                    ()
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
                    |> Game.Area.fromStack ( toFloat i * 150, 0 )
                        { view =
                            \_ () ->
                                ( "draggable__card"
                                , \a -> View.Component.defaultCard (attrs ++ a)
                                )
                        , empty =
                            ( "draggable__empty_" ++ String.fromInt i
                            , \a -> View.Component.empty (attrs ++ a)
                            )
                        }
            )
        |> List.concat
        |> Game.Area.toHtml [ Html.Attributes.style "height" "200px" ]
        |> List.singleton
        |> Html.div [ Game.Card.perspective ]


pile :
    Int
    ->
        { position : ( Float, Float )
        , onStartDragging : Maybe msg
        , onStopDragging : Maybe msg
        , onEntering : Maybe msg
        , onLeaving : Maybe msg
        }
    -> List { cardId : CardId, card : card, asPhantom : Bool }
    -> List (AreaEntity msg)
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
                stackItem
                    |> Game.Entity.mapPosition
                        (Tuple.mapBoth
                            ((+) 0)
                            ((+) (-4 * toFloat i))
                        )
                    |> Game.Entity.withRotation
                        (if stackItem.content.asPhantom then
                            pi / 16

                         else
                            stackItem.rotation
                        )
            )
        |> List.map
            (\stackItem ->
                if stackItem.content.asPhantom then
                    { stackItem | zIndex = 100 }

                else
                    stackItem
            )
        |> Game.Area.fromStack args.position
            { view =
                \_ card ->
                    ( "pile__" ++ String.fromInt card.cardId.cardId
                    , \a ->
                        View.Component.defaultCard
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
            , empty = ( "pile__empty__" ++ String.fromInt index, \a -> View.Component.empty (Html.Attributes.style "z-index" "0" :: attrs ++ a) )
            }
