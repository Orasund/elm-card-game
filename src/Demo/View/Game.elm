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
        , playCard : msg
        }
    -> List ( String, Entity (List (Attribute msg) -> Html msg) )
arena ( x, y ) args =
    [ args.yourPick
        |> Maybe.map Game.Entity.new
        |> Maybe.map List.singleton
        |> Maybe.withDefault []
        |> Game.Area.fromStack ( -100, 0 )
            { view =
                \_ ( cardId, card ) ->
                    ( "card_" ++ String.fromInt cardId
                    , \attrs ->
                        Demo.View.Card.toEntity [] True card
                            |> Game.Entity.toHtml attrs identity
                    )
            , empty = ( "selected_0", \attrs -> Game.Card.empty attrs "Select a card" )
            }
    , [ ( "vs"
        , (\attrs ->
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
        )
      ]
    , args.opponentPick
        |> Maybe.map
            (\( cardId, card ) ->
                card
                    |> Demo.View.Card.toEntity [] False
                    |> Game.Entity.map (Tuple.pair cardId)
            )
        |> Maybe.map List.singleton
        |> Maybe.withDefault []
        |> Game.Area.fromStack ( 100, 0 )
            { view =
                \_ ( cardId, fun ) ->
                    ( "card_" ++ String.fromInt cardId
                    , \attrs -> fun (Html.Events.onClick args.playCard :: attrs)
                    )
            , empty = ( "selected_1", \attrs -> Game.Card.empty attrs "No Card" )
            }
    ]
        |> List.concat
        |> List.map (Tuple.mapSecond (Game.Entity.mapPosition (Tuple.mapBoth ((+) x) ((+) y))))


hand : ( Float, Float ) -> { selectCard : CardId -> msg, selected : Maybe CardId } -> List ( CardId, Card ) -> List ( String, Entity (List (Attribute msg) -> Html msg) )
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
        |> (\list ->
                list
                    |> Game.Pile.mapPosition
                        (\i ( _, _ ) _ ->
                            ( (toFloat i - (toFloat (List.length list) - 1) / 2) * 30, 0 )
                        )
           )
        |> Game.Area.fromStack pos
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


hiddenHand : ( Float, Float ) -> { selected : Maybe CardId } -> List ( CardId, Card ) -> List ( String, Entity (List (Attribute msg) -> Html msg) )
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
        |> Game.Area.fromStack pos
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


toHtml :
    { selectCard : CardId -> msg
    , selected : Maybe CardId
    , playCard : msg
    }
    -> Game
    -> Html msg
toHtml args game =
    [ game
        |> Demo.Game.handOf Demo.Player.opponent
        |> hiddenHand ( 0, 0 ) { selected = game.opponentPick }
    , arena ( 0, 150 + 16 )
        { yourPick =
            args.selected
                |> Maybe.andThen (\cardId -> game.cards |> Dict.get cardId |> Maybe.map (Tuple.pair cardId))
        , opponentPick =
            game.opponentPick
                |> Maybe.andThen (\cardId -> game.cards |> Dict.get cardId |> Maybe.map (Tuple.pair cardId))
        , playCard = args.playCard
        }
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