module Demo.Card exposing (..)


type alias CardId =
    Int


type Card
    = Rock
    | Paper
    | Scissors


values : List Card
values =
    [ Rock, Paper, Scissors ]


wonAgainst : Card -> Card -> Maybe Bool
wonAgainst card1 card2 =
    case ( card1, card2 ) of
        ( Rock, Paper ) ->
            Just True

        ( Rock, Scissors ) ->
            Just False

        ( Paper, Scissors ) ->
            Just True

        ( Paper, Rock ) ->
            Just False

        ( Scissors, Rock ) ->
            Just True

        ( Scissors, Paper ) ->
            Just False

        _ ->
            Nothing
