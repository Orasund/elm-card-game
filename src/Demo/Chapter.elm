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
                        Random.step (Demo.Game.play selected model.game) model.seed
                            |> (\( game, seed ) ->
                                    { model
                                        | game = game
                                        , selected = Nothing
                                        , seed = seed
                                    }
                               )
                    )
                |> Maybe.withDefault model

        Restart ->
            Random.step Demo.Game.init model.seed
                |> (\( game, seed ) -> { model | game = game, seed = seed, selected = Nothing })


view : Model -> Html Msg
view model =
    Demo.View.Game.toHtml
        { selectCard = SelectCard
        , selected = model.selected
        , playCard = PlayCard
        , restart = Restart
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
