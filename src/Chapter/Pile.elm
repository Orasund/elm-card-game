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
                    , ( "withMovement", View.Pile.below )
                    , ( "withRotation", View.Pile.rotated )
                    , ( "randomRotation and randomMovement", View.Pile.random )
                    , ( "withRotation and withMovement", View.Pile.hand )
                    ]
              )
            ]
        |> ElmBook.Chapter.renderWithComponentList ""
