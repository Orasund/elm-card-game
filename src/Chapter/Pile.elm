module Chapter.Pile exposing (..)

import ElmBook.Chapter exposing (Chapter)
import View.Component
import View.Pile


chapter : Chapter msg
chapter =
    ElmBook.Chapter.chapter "Game.Pile"
        |> ElmBook.Chapter.withComponentList
            [ ( "Pile"
              , View.Component.list
                    [ ( "Single Card", View.Pile.singleCard )
                    , ( "withPolarPosition", View.Pile.below )
                    , ( "withLinearRotation", View.Pile.rotated )
                    , ( "Randomness", View.Pile.random )
                    , ( "withLinearRotation and withPolarPosition", View.Pile.hand )
                    ]
              )
            ]
        |> ElmBook.Chapter.renderWithComponentList ""
