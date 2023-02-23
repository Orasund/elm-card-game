module Game.Entity exposing (..)

{-|


# Transformation

@docs Transformation, transform, move, rotate, zoom

-}

import Html exposing (Attribute, Html, a)
import Html.Attributes


type alias Entity a =
    { position : ( Float, Float )
    , rotation : Float
    , customTransformations : List Transformation
    , zIndex : Int
    , content : a
    }


new : a -> Entity a
new a =
    { position = ( 0, 0 )
    , rotation = 0
    , customTransformations = []
    , zIndex = 1
    , content = a
    }


map : (a -> b) -> Entity a -> Entity b
map fun i =
    { position = i.position
    , rotation = i.rotation
    , content = fun i.content
    , customTransformations = i.customTransformations
    , zIndex = i.zIndex
    }


attributes : Entity a -> List (Attribute msg)
attributes entity =
    [ [ move entity.position
      , rotate entity.rotation
      ]
        ++ entity.customTransformations
        |> transform
    , Html.Attributes.style "z-index" (String.fromInt entity.zIndex)
    ]


toHtml : List (Attribute msg) -> (a -> List (Attribute msg) -> Html msg) -> Entity a -> Html msg
toHtml attrs fun entity =
    fun entity.content (attributes entity ++ attrs)


withRotation : Float -> Entity a -> Entity a
withRotation float entity =
    { entity | rotation = float }


withPosition : ( Float, Float ) -> Entity a -> Entity a
withPosition pos entity =
    { entity | position = pos }


withZIndex : Int -> Entity a -> Entity a
withZIndex int entity =
    { entity | zIndex = int }


withCustomTransformations : List Transformation -> Entity a -> Entity a
withCustomTransformations list entity =
    { entity | customTransformations = list }


mapRotation : (Float -> Float) -> Entity a -> Entity a
mapRotation fun entity =
    withRotation (fun entity.rotation) entity


mapPosition : (( Float, Float ) -> ( Float, Float )) -> Entity a -> Entity a
mapPosition fun entity =
    withPosition (fun entity.position) entity


mapZIndex : (Int -> Int) -> Entity a -> Entity a
mapZIndex fun entity =
    withZIndex (fun entity.zIndex) entity


mapCustomTransformations : (List Transformation -> List Transformation) -> Entity a -> Entity a
mapCustomTransformations fun entity =
    withCustomTransformations (fun entity.customTransformations) entity


flippable :
    List (Attribute msg)
    ->
        { front : Entity (List (Attribute msg) -> Html msg)
        , back : Entity (List (Attribute msg) -> Html msg)
        , faceUp : Bool
        }
    -> Entity (List (Attribute msg) -> Html msg)
flippable attrs args =
    (\a ->
        [ args.front
            |> mapCustomTransformations ((::) (flip 0))
            |> toHtml [ Html.Attributes.style "position" "absolute" ] identity
        , args.back
            |> mapCustomTransformations ((::) (flip pi))
            |> toHtml [ Html.Attributes.style "position" "absolute" ] identity
        ]
            |> Html.div
                ([ Html.Attributes.style "position" "relative"
                 , Html.Attributes.style "transition" "transform 0.5s"
                 , Html.Attributes.style "transform-style" "preserve-3d"
                 , Html.Attributes.style "height" "200px"
                 , Html.Attributes.style "width" (String.fromFloat (200 * 2 / 3) ++ "px")
                 ]
                    ++ a
                    ++ attrs
                )
    )
        |> new
        |> (if not args.faceUp then
                withCustomTransformations [ flip pi ]

            else
                identity
           )


{-| A transformation string
-}
type alias Transformation =
    String


{-| Add transformations to a card
-}
transform : List Transformation -> Attribute msg
transform list =
    (if list == [] then
        "unset"

     else
        list
            |> String.join " "
    )
        |> Html.Attributes.style "transform"


{-| Scale the card
-}
scale : Float -> Transformation
scale float =
    "scale("
        ++ String.fromFloat float
        ++ ","
        ++ String.fromFloat float
        ++ ")"


{-| Rotate the card by a radial.
-}
rotate : Float -> Transformation
rotate float =
    "rotate("
        ++ String.fromFloat float
        ++ "rad)"


{-| Move the card
-}
move : ( Float, Float ) -> Transformation
move ( x, y ) =
    "translate("
        ++ String.fromFloat x
        ++ "px,"
        ++ String.fromFloat y
        ++ "px)"


{-| Only works if the outer div has a `perspective` Attribute
-}
flip : Float -> Transformation
flip float =
    "rotateY("
        ++ String.fromFloat float
        ++ "rad)"


perspective : Attribute msg
perspective =
    Html.Attributes.style "perspective" "1000px"
