module Demo.Chapter exposing (..)

import Demo.Card exposing (CardId)
import Demo.Game exposing (Game)
import Demo.View.Game
import ElmBook.Actions
import ElmBook.Chapter exposing (Chapter)
import Html exposing (Html)
import Random exposing (Seed)


type alias Model =
    { game : Game
    , selected : Maybe CardId
    , turnedOver : Bool
    , seed : Seed
    }


type Msg
    = SelectCard CardId
    | PlayCard
    | Restart


init : Model
init =
    let
        ( game, seed ) =
            Random.initialSeed 39
                |> Random.step Demo.Game.init
    in
    { game = game
    , selected = Nothing
    , seed = seed
    , turnedOver = False
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectCard cardId ->
            { model | selected = Just cardId }

        PlayCard ->
            model.selected
                |> Maybe.map
                    (\selected ->
                        if model.turnedOver then
                            Random.step (Demo.Game.play selected model.game) model.seed
                                |> (\( game, seed ) ->
                                        { model
                                            | game = game
                                            , selected = Nothing
                                            , turnedOver = False
                                            , seed = seed
                                        }
                                   )

                        else
                            { model | turnedOver = True }
                    )
                |> Maybe.withDefault model

        Restart ->
            Random.step Demo.Game.init model.seed
                |> (\( game, seed ) ->
                        { model
                            | game = game
                            , seed = seed
                            , selected = Nothing
                            , turnedOver = False
                        }
                   )


view : Model -> Html Msg
view model =
    Demo.View.Game.toHtml
        { selectCard =
            if model.turnedOver then
                \_ -> PlayCard

            else
                SelectCard
        , selected = model.selected
        , playCard = PlayCard
        , restart = Restart
        , turnedOver = model.turnedOver
        }
        model.game


chapter : { get : model -> Model, setTo : model -> Model -> model } -> Chapter model
chapter args =
    ElmBook.Chapter.chapter "Rock Paper Scissors"
        |> ElmBook.Chapter.renderStatefulComponent
            (\m ->
                m
                    |> args.get
                    |> view
                    |> Html.map
                        (\msg ->
                            ElmBook.Actions.updateState
                                (\model ->
                                    model
                                        |> args.get
                                        |> update msg
                                        |> args.setTo model
                                )
                        )
            )
