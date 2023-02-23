module View.Component exposing (..)

import Game.Card
import Html exposing (Attribute, Html)
import Html.Attributes


image : String
image =
    "https://upload.wikimedia.org/wikipedia/commons/f/f3/Elm_logo.svg"


empty : List (Attribute msg) -> Html msg
empty attrs =
    Game.Card.empty attrs "No Card"


defaultCard : List (Attribute msg) -> Html msg
defaultCard attrs =
    [ [ Html.div [] [ Html.text "Elm" ]
      , Html.div [] [ Html.text "🌳" ]
      ]
        |> Game.Card.header []
    , image |> Game.Card.fillingImage []
    , Html.text "Removes runtime exceptions"
        |> Game.Card.description []
    ]
        |> Game.Card.default attrs


defaultBack : List (Attribute msg) -> Html msg
defaultBack attrs =
    [ image |> Game.Card.fillingImage [ Html.Attributes.style "filter" "grayscale(1)" ]
    ]
        |> Game.Card.default attrs


list : List ( String, Html msg ) -> Html msg
list l =
    l
        |> List.map
            (\( subtitle, content ) ->
                [ content
                , [ Html.text subtitle ]
                    |> Html.div [ Html.Attributes.style "text-align" "center" ]
                ]
                    |> Html.div
                        [ Html.Attributes.style "display" "flex"
                        , Html.Attributes.style "flex-direction" "column"
                        , Html.Attributes.style "gap" "8px"
                        ]
            )
        |> Html.div
            [ Html.Attributes.style "display" "flex"
            , Html.Attributes.style "flex-direction" "row"
            , Html.Attributes.style "flex-wrap" "wrap"
            , Html.Attributes.style "justify-content" "space-between"
            ]
