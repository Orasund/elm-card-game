module Demo.View.Game exposing (..)

import Demo.Card exposing (Card, CardId)
import Demo.Game exposing (Game)
import Demo.Player
import Demo.View.Card
import Dict
import Game.Area
import Game.Card
import Game.Entity exposing (Entity)
import Game.Pile
import Html exposing (Attribute, Html)
import Html.Attributes
import Html.Events


arena :
    ( Float, Float )
    ->
        { yourPick : Maybe ( CardId, Card )
        , opponentPick : Maybe ( CardId, Card )
        , turnedOver : Bool
        , playCard : msg
        }
    -> List (Entity ( String, List (Attribute msg) -> Html msg ))
arena ( x, y ) args =
    [ args.yourPick
        |> Maybe.map Game.Entity.new
        |> Maybe.map List.singleton
        |> Maybe.withDefault []
        |> Game.Area.fromPile ( -100, 0 )
            { view =
                \_ ( cardId, card ) ->
                    ( "card_" ++ String.fromInt cardId
                    , \attrs ->
                        Demo.View.Card.toEntity [] True card
                            |> Game.Entity.toHtml attrs identity
                    )
            , empty = ( "selected_0", \attrs -> Game.Card.empty attrs "Select a card" )
            }
    , [ (\attrs ->
            Html.text "vs."
                |> List.singleton
                |> Html.h1 attrs
                |> List.singleton
                |> Html.div
                    [ Html.Attributes.style "display" "flex"
                    , Html.Attributes.style "justify-content" "center"
                    , Html.Attributes.style "align-items" "center"
                    , Html.Attributes.style "height" "200px"
                    ]
        )
            |> Game.Entity.new
            |> Game.Entity.map (Tuple.pair "vs.")
      ]
    , args.opponentPick
        |> Maybe.map
            (\( cardId, card ) ->
                card
                    |> Demo.View.Card.toEntity [] args.turnedOver
                    |> Game.Entity.map (Tuple.pair cardId)
            )
        |> Maybe.map List.singleton
        |> Maybe.withDefault []
        |> Game.Area.fromPile ( 100, 0 )
            { view =
                \_ ( cardId, fun ) ->
                    ( "card_" ++ String.fromInt cardId
                    , \attrs -> fun (Html.Events.onClick args.playCard :: attrs)
                    )
            , empty = ( "selected_1", \attrs -> Game.Card.empty attrs "No Card" )
            }
    ]
        |> List.concat
        |> List.map (Game.Entity.mapPosition (Tuple.mapBoth ((+) x) ((+) y)))


hand : ( Float, Float ) -> { selectCard : CardId -> msg, selected : Maybe CardId } -> List ( CardId, Card ) -> List (Entity ( String, List (Attribute msg) -> Html msg ))
hand pos args l =
    l
        |> List.filterMap
            (\( cardId, card ) ->
                if Just cardId /= args.selected then
                    card
                        |> Demo.View.Card.toEntity [] True
                        |> Game.Entity.map (Tuple.pair cardId)
                        |> Just

                else
                    Nothing
            )
        |> Game.Pile.withPolarPosition
            { minDistance = -50
            , maxDistance = 50
            , minAngle = -pi / 32
            , maxAngle = pi / 32
            }
        |> Game.Pile.withLinearRotation { min = -pi / 16, max = pi / 16 }
        |> Game.Area.fromPile pos
            { view =
                \_ ( cardId, fun ) ->
                    ( "card_" ++ String.fromInt cardId
                    , \attrs -> fun (attrs ++ [ Html.Events.onClick (args.selectCard cardId) ])
                    )
            , empty =
                ( "empty_stack"
                , \attrs -> Html.div attrs []
                )
            }


hiddenHand : ( Float, Float ) -> { selected : Maybe CardId } -> List ( CardId, Card ) -> List (Entity ( String, List (Attribute msg) -> Html msg ))
hiddenHand pos args l =
    l
        |> List.filterMap
            (\( cardId, card ) ->
                if Just cardId /= args.selected then
                    card
                        |> Demo.View.Card.toEntity [] False
                        |> Game.Entity.map (Tuple.pair cardId)
                        |> Game.Entity.mapCustomTransformations ((++) [ Game.Entity.scale (1 / 2) ])
                        |> Just

                else
                    Nothing
            )
        |> (\list ->
                list
                    |> Game.Pile.mapPosition
                        (\i ( _, _ ) _ ->
                            ( (toFloat i - (toFloat (List.length list) - 1) / 2) * 30, 0 )
                        )
           )
        |> Game.Area.fromPile pos
            { view =
                \_ ( cardId, fun ) ->
                    ( "card_" ++ String.fromInt cardId
                    , fun
                    )
            , empty =
                ( "empty_stack"
                , \attrs -> Html.div attrs []
                )
            }


discardPile : ( Float, Float ) -> List ( CardId, Card ) -> List (Entity ( String, List (Attribute msg) -> Html msg ))
discardPile ( x, y ) l =
    l
        |> List.map
            (\( cardId, card ) ->
                card
                    |> Demo.View.Card.toEntity [] True
                    |> Game.Entity.map (Tuple.pair ("card_" ++ String.fromInt cardId))
                    |> Game.Entity.mapCustomTransformations ((++) [ Game.Entity.scale (1 / 2) ])
            )
        |> Game.Pile.mapZIndex (\i _ -> (+) (i + 1))
        |> Game.Pile.mapPosition (\i _ _ -> ( x, toFloat i * 15 + y - (toFloat (List.length l) * 15 / 2) ))


toHtml :
    { selectCard : CardId -> msg
    , selected : Maybe CardId
    , turnedOver : Bool
    , playCard : msg
    , restart : msg
    }
    -> Game
    -> Html msg
toHtml args game =
    [ [ game
            |> Demo.Game.handOf Demo.Player.opponent
            |> hiddenHand ( 0, 0 )
                { selected = game.opponentPick
                }
      , arena ( 0, 150 + 16 )
            { yourPick =
                args.selected
                    |> Maybe.andThen (\cardId -> game.cards |> Dict.get cardId |> Maybe.map (Tuple.pair cardId))
            , opponentPick =
                game.opponentPick
                    |> Maybe.andThen (\cardId -> game.cards |> Dict.get cardId |> Maybe.map (Tuple.pair cardId))
            , turnedOver =
                args.turnedOver
            , playCard = args.playCard
            }
      , game.discardPile
            |> List.filterMap (\cardId -> game.cards |> Dict.get cardId |> Maybe.map (Tuple.pair cardId))
            |> discardPile ( -216, 150 + 16 )
      , game
            |> Demo.Game.handOf Demo.Player.you
            |> hand ( 0, 150 + 32 + 200 ) { selectCard = args.selectCard, selected = args.selected }
      ]
        |> List.concat
        |> Game.Area.toHtml
            [ Html.Attributes.style "height" "600px"
            , Html.Attributes.style "justify-content" "center"
            , Game.Entity.perspective
            ]
    , Demo.Game.gameOver game
        |> Maybe.map
            (\reason ->
                [ Html.text reason |> List.singleton |> Html.h1 [ Html.Attributes.style "font-size" "64px" ]
                , Html.text "Click to restart" |> List.singleton |> Html.div []
                ]
                    |> Html.div
                        [ Html.Attributes.style "height" "600px"
                        , Html.Attributes.style "width" "100%"
                        , Html.Attributes.style "background-color" "rgba(0, 0, 0, 0.2)"
                        , Html.Attributes.style "z-index" "1000"
                        , Html.Attributes.style "position" "absolute"
                        , Html.Attributes.style "top" "0"
                        , Html.Attributes.style "left" "0"
                        , Html.Events.onClick args.restart
                        , Html.Attributes.style "display" "flex"
                        , Html.Attributes.style "flex-direction" "column"
                        , Html.Attributes.style "backdrop-filter" "blur(4px)"
                        , Html.Attributes.style "align-items" "center"
                        , Html.Attributes.style "justify-content" "center"
                        ]
            )
        |> Maybe.withDefault (Html.text "")
    ]
        |> Html.div
            [ Html.Attributes.style "position" "relative"
            ]
