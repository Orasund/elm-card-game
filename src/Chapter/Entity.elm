module Chapter.Entity exposing (..)

import ElmBook.Actions
import ElmBook.Chapter exposing (Chapter)
import Example.FlippableCard
import Html
import View.Component
import View.Entity


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
                        [ ( "move", View.Entity.move )
                        , ( "rotate", View.Entity.rotate )
                        ]
              )
            , ( "Transformations"
              , \_ ->
                    View.Component.list
                        [ ( "mapRotation", View.Entity.mapRotation )
                        , ( "mapPosition", View.Entity.mapPosition )
                        , ( "scale", View.Entity.scale )
                        , ( "flip", View.Entity.flip )
                        ]
              )
            , ( "Perspective"
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
            """Entities are an abstraction of CSS-Transformations. You can move and rotate entities, pile them together and apply transformations to piles of entities.
            
You can use `Game.Entity.toHtml` to turn an entity into Html."""
