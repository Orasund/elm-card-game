module Main exposing (..)

import Chapter.Area
import Chapter.Card
import Chapter.Customization
import Chapter.Entity
import Demo.Chapter
import ElmBook exposing (Book)
import ElmBook.Chapter
import ElmBook.StatefulOptions
import ElmBook.ThemeOptions
import Html


type alias Model =
    { area : Chapter.Area.State
    , card : Chapter.Card.Model
    , demo : Demo.Chapter.Model
    }


init : Model
init =
    { area = Chapter.Area.init
    , card = Chapter.Card.init
    , demo = Demo.Chapter.init
    }


main : Book Model
main =
    ElmBook.book "Elm-Card-Game"
        |> ElmBook.withThemeOptions
            [ ElmBook.ThemeOptions.useHashBasedNavigation
            , ElmBook.ThemeOptions.globals
                [ Html.node "style" [] [ Html.text """
                    .elm-book-action-log-preview-empty-wrapper,
                    .elm-book--wrapper--menu--header{
                        display: none
                    }
                """ ] ]
            ]
        |> ElmBook.withStatefulOptions
            [ ElmBook.StatefulOptions.initialState init ]
        |> ElmBook.withChapterGroups
            [ ( "Documentation"
              , [ Chapter.Card.chapter
                , Chapter.Entity.chapter { get = .card, setTo = \model state -> { model | card = state } }
                , Chapter.Area.chapter { get = .area, setTo = \model state -> { model | area = state } }
                ]
              )
            , ( "Demo", [ Demo.Chapter.chapter { get = .demo, setTo = \model state -> { model | demo = state } } ] )
            , ( "Development"
              , [ Chapter.Customization.chapter
                , ElmBook.Chapter.chapterLink
                    { title = "👋 Created by Lucas Payr"
                    , url = "https://www.linkedin.com/in/lucas-payr-8462911b9/"
                    }
                ]
              )
            ]
