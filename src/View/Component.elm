module View.Component exposing (..)

import Game.Card
import Game.Entity exposing (Entity)
import Html exposing (Attribute, Html)
import Html.Attributes


image : String
image =
    "/assert/Elm_logo.svg"


empty : List (Attribute msg) -> Html msg
empty attrs =
    Game.Card.empty attrs "No Card"


defaultCard : Entity (List (Attribute msg) -> Html msg)
defaultCard =
    (\a ->
        [ [ Html.div [] [ Html.text "Elm" ]
          , Html.div [] [ Html.text "🌳" ]
          ]
            |> Game.Card.header []
        , image |> Game.Card.fillingImage []
        , Html.text "Removes runtime exceptions"
            |> Game.Card.description []
        ]
            |> Game.Card.default a
    )
        |> Game.Entity.new


defaultBack : Entity (List (Attribute msg) -> Html msg)
defaultBack =
    (\attrs ->
        [ image |> Game.Card.fillingImage [ Html.Attributes.style "filter" "grayscale(1)" ]
        ]
            |> Game.Card.default attrs
    )
        |> Game.Entity.new


coin : List (Attribute msg) -> Html msg
coin attrs =
    [ image
        |> Game.Card.fillingImage [ Html.Attributes.style "filter" "sepia(1)" ]
        |> Game.Card.coin
            [ Html.Attributes.style "border-radius" "100%"
            , Html.Attributes.style "height" "100px"
            , Game.Card.ratio 1
            ]
    ]
        |> Html.div ([] ++ attrs)


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
