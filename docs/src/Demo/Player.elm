module Demo.Player exposing (..)

import Demo.Card exposing (CardId)


type alias PlayerId =
    Int


you : PlayerId
you =
    0


opponent : PlayerId
opponent =
    1


type alias Player =
    List CardId


init : List CardId -> Player
init hand =
    hand
