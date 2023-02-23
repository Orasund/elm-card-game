module Chapter.Entity exposing (..)

import ElmBook.Actions
import ElmBook.Chapter exposing (Chapter)
import Example.FlippableCard
import Html
import View.Card
import View.Component


type alias Model =
    { flippableCard : Example.FlippableCard.Model }


init : Model
init =
    { flippableCard = Example.FlippableCard.init }


chapter : { get : model -> Model, setTo : model -> Model -> model } -> Chapter model
chapter args =
    ElmBook.Chapter.chapter "Game.Entity"
        |> ElmBook.Chapter.withChapterInit
            (\model ->
                ( args.setTo model init, Cmd.none )
            )
        |> ElmBook.Chapter.withStatefulComponentList
            [ ( "Entity"
              , \_ ->
                    View.Component.list
                        [ ( "withRotate (pi/2)", View.Card.rotated )
                        , ( "withTranslate (0,-50)", View.Card.move )
                        ]
              )
            , ( "Transformations"
              , \_ ->
                    View.Component.list
                        [ ( "scale (1/2)", View.Card.small )
                        , ( "flip (pi/4)", View.Card.flipped )
                        ]
              )
            , ( "Flippable Cards"
              , \model ->
                    model
                        |> args.get
                        |> (\state ->
                                View.Component.list
                                    [ ( "Click to flip the card"
                                      , Example.FlippableCard.view state.flippableCard
                                            |> Html.map
                                                (\msg ->
                                                    ElmBook.Actions.updateState
                                                        (\m ->
                                                            m
                                                                |> args.get
                                                                |> (\s ->
                                                                        s.flippableCard
                                                                            |> Example.FlippableCard.update msg
                                                                            |> (\a -> { s | flippableCard = a })
                                                                   )
                                                                |> args.setTo m
                                                        )
                                                )
                                      )
                                    ]
                           )
              )
            ]
        |> ElmBook.Chapter.renderWithComponentList
            ""
