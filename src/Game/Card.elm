module Game.Card exposing
    ( default, empty, back, coin
    , title, header, fillingImage, description
    , ratio, backgroundImage
    )

{-| This module contains functions to display cards.


# Styles

@docs default, empty, back, coin


# Parts

@docs title, header, fillingImage, description


# Attributes

@docs ratio, backgroundImage

-}

import Html exposing (Attribute, Html)
import Html.Attributes


{-| Displays an default view of a card.
-}
default : List (Attribute msg) -> List (Html msg) -> Html msg
default attrs content =
    Html.div
        ([ --Flexbox
           Html.Attributes.style "display" "flex"
         , Html.Attributes.style "flex-direction" "column"

         -- Aspect-ratio
         , ratio 0.66
         , Html.Attributes.style "height" "200px"

         -- Rounded Edges
         , Html.Attributes.style "border-radius" "16px"
         , Html.Attributes.style "overflow" "hidden"

         -- Defaults
         , Html.Attributes.style "background-color" "white"
         , Html.Attributes.style "border-width" "1px"
         , Html.Attributes.style "border-style" "solid"
         , Html.Attributes.style "border-color" "rgba(0, 0, 0, 0.2)"
         , Html.Attributes.style "font-size" "0.8em"
         , Html.Attributes.style "z-index" "1"

         -- 3d Effect when flipping
         , Html.Attributes.style "backface-visibility" "hidden"
         ]
            ++ attrs
        )
        content


{-| Display an empty card-sized space with some text
-}
empty : List (Attribute msg) -> String -> Html msg
empty attrs string =
    default
        ([ Html.Attributes.style "border-style" "dashed"
         , Html.Attributes.style "color" "rgba(0, 0, 0, 0.5)"
         , Html.Attributes.style "justify-content" "center"
         , Html.Attributes.style "align-items" "center"
         , Html.Attributes.style "background-color" "none"
         , Html.Attributes.style "z-index" "0"
         ]
            ++ attrs
        )
        [ Html.div [ Html.Attributes.style "display" "flex" ] [ Html.text string ] ]


{-| Displays a card with the content centered. Use this to design your card backs.
-}
back : List (Attribute msg) -> Html msg -> Html msg
back attrs content =
    default
        ([ Html.Attributes.style "justify-content" "center"
         , Html.Attributes.style "align-items" "center"
         ]
            ++ attrs
        )
        [ content ]


{-| Displays a coin.
-}
coin : List (Attribute msg) -> Html msg -> Html msg
coin attrs content =
    default
        ([ Html.Attributes.style "justify-content" "center"
         , Html.Attributes.style "align-items" "center"
         , Html.Attributes.style "border-radius" "100%"
         , ratio 1
         , Html.Attributes.style "height" "100px"
         ]
            ++ attrs
        )
        [ content ]


{-| Display a text with some padding
-}
title : List (Attribute msg) -> Html msg -> Html msg
title attrs content =
    Html.div
        ([ Html.Attributes.style "padding" "8px 8px"
         , Html.Attributes.style "display" "flex"
         ]
            ++ attrs
        )
        [ content ]


{-| Sets the background to an image
-}
backgroundImage : String -> List (Attribute msg)
backgroundImage src =
    [ Html.Attributes.style "background-image" ("url(" ++ src ++ ")")
    , Html.Attributes.style "background-size" "cover"
    , Html.Attributes.style "background-position" "center"
    ]


{-| Displays a image that will take up as much space as possible
-}
fillingImage : List (Attribute msg) -> String -> Html msg
fillingImage attrs src =
    Html.div
        ([ Html.Attributes.style "flex-grow" "1"
         , Html.Attributes.style "display" "flex"
         ]
            ++ backgroundImage src
            ++ attrs
        )
        []


{-| Displays a content with a padding
-}
description : List (Attribute msg) -> Html msg -> Html msg
description attrs content =
    Html.div
        ([ Html.Attributes.style "display" "flex"
         , Html.Attributes.style "padding" "8px 8px"
         ]
            ++ attrs
        )
        [ content ]


{-| A row on top of the card. It uses flexbox.
-}
header : List (Attribute msg) -> List (Html msg) -> Html msg
header attrs content =
    Html.div
        ([ Html.Attributes.style "display" "flex"
         , Html.Attributes.style "flex-direction" "row"
         , Html.Attributes.style "justify-content" "space-between"
         , Html.Attributes.style "padding" "8px 8px"
         ]
            ++ attrs
        )
        content


{-| Defines a aspect-ratio of an element. The ratio is `width/height`.
-}
ratio : Float -> Attribute msg
ratio float =
    float
        |> String.fromFloat
        |> Html.Attributes.style "aspect-ratio"
