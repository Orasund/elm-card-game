module Chapter.Card exposing (..)

import ElmBook.Chapter exposing (Chapter)
import Example.FlippableCard
import View.Card
import View.Component


type alias Model =
    { flippableCard : Example.FlippableCard.Model }


init : Model
init =
    { flippableCard = Example.FlippableCard.init }


chapter : Chapter model
chapter =
    ElmBook.Chapter.chapter "Game.Card"
        |> ElmBook.Chapter.withComponentList
            [ ( "Views"
              , View.Component.list
                    [ ( "empty", View.Card.empty )
                    , ( "default", View.Card.default )
                    , ( "back", View.Card.back )
                    , ( "coin", View.Card.coin )
                    ]
              )
            , ( "Ratios"
              , View.Component.list
                    [ ( "ratio (2/3)", View.Card.default )
                    , ( "ratio 1", View.Card.square )
                    , ( "ratio (3/2)", View.Card.horizontal )
                    ]
              )
            , ( "Layouts"
              , View.Component.list
                    [ ( "element", View.Card.element )
                    , ( "row", View.Card.row )
                    , ( "backgroundImage", View.Card.backgroundImage )
                    , ( "fillingImage", View.Card.fullImage )
                    ]
              )
            ]
        |> ElmBook.Chapter.renderWithComponentList """Cards are styled `div` nodes that take use of Flexbox.
        
It has a couple of default styling defined that are meant to be overwritten.

If you want to use the package without this module, make sure your custom cards have the CSS-style `backface-visibility` set to `hidden`. This is required in order for `Game.Entity.flip` to work.
        """
