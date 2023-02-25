module Demo.Game exposing (..)

import Demo.Card exposing (Card, CardId)
import Demo.Player exposing (Player, PlayerId)
import Dict exposing (Dict)
import Random exposing (Generator)


type alias Game =
    { players : Dict PlayerId Player
    , cards : Dict CardId Card
    , opponentPick : Maybe CardId
    }


init : Generator Game
init =
    Demo.Card.values
        |> List.concatMap (List.repeat 4)
        |> (\list ->
                Random.list (List.length list) (Random.float 0 1)
                    |> Random.map
                        (\randomList ->
                            List.map2 Tuple.pair
                                list
                                randomList
                                |> List.sortBy Tuple.second
                                |> List.map Tuple.first
                        )
           )
        |> Random.map (List.indexedMap Tuple.pair)
        |> Random.andThen
            (\deck ->
                Random.int 6 11
                    |> Random.map
                        (\opponentPick ->
                            { players =
                                [ ( Demo.Player.you, List.range 0 5 |> Demo.Player.init )
                                , ( Demo.Player.opponent
                                  , List.range 6 11 |> Demo.Player.init
                                  )
                                ]
                                    |> Dict.fromList
                            , cards = Dict.fromList deck
                            , opponentPick = Just opponentPick
                            }
                        )
            )


handOf : PlayerId -> Game -> List ( CardId, Card )
handOf playerId game =
    game.players
        |> Dict.get playerId
        |> Maybe.withDefault []
        |> List.filterMap
            (\cardId ->
                game.cards
                    |> Dict.get cardId
                    |> Maybe.map (Tuple.pair cardId)
            )


play : CardId -> Game -> Generator Game
play cardId game =
    game.opponentPick
        |> Maybe.map
            (\opponentPick ->
                let
                    won =
                        Maybe.map2 Demo.Card.wonAgainst
                            (game.cards |> Dict.get opponentPick)
                            (game.cards |> Dict.get cardId)
                            |> Maybe.andThen identity
                            |> Maybe.withDefault True

                    opponent =
                        game.players
                            |> Dict.get Demo.Player.opponent
                            |> Maybe.withDefault (Demo.Player.init [])
                            |> List.filter (\id -> Just id /= game.opponentPick)
                            |> (if not won then
                                    (++) [ cardId, opponentPick ]

                                else
                                    identity
                               )

                    you =
                        game.players
                            |> Dict.get Demo.Player.you
                            |> Maybe.withDefault (Demo.Player.init [])
                            |> List.filter ((/=) cardId)
                            |> (if won then
                                    (++) [ cardId, opponentPick ]

                                else
                                    identity
                               )
                in
                (case opponent of
                    head :: tail ->
                        Random.uniform head tail
                            |> Random.map Just

                    [] ->
                        Random.constant Nothing
                )
                    |> Random.map
                        (\newOpponentPick ->
                            { game
                                | players =
                                    game.players
                                        |> Dict.update Demo.Player.you (\_ -> Just you)
                                        |> Dict.update Demo.Player.opponent (\_ -> Just opponent)
                                , opponentPick =
                                    newOpponentPick
                            }
                        )
            )
        |> Maybe.withDefault (Random.constant game)
