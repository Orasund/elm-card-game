module Game.Entity exposing
    ( Entity, new, toAttributes, toHtml
    , map, mapCustomTransformations, mapPosition, mapRotation, mapZIndex
    , flippable, perspective
    , Transformation, transform, move, rotate, scale, flip
    )

{-| module for working with entities.


# Entity

@docs Entity, new, toAttributes, toHtml

@docs map, mapCustomTransformations, mapPosition, mapRotation, mapZIndex

@docs flippable, perspective


# Transformation

@docs Transformation, transform, move, rotate, scale, flip

-}

import Html exposing (Attribute, Html)
import Html.Attributes


{-| A entity allows for different relative transformations like rotating or moving by a relative amount.
-}
type alias Entity a =
    { position : ( Float, Float )
    , rotation : Float
    , customTransformations : List Transformation
    , zIndex : Int
    , content : a
    }


{-| construct a entity
-}
new : a -> Entity a
new a =
    { position = ( 0, 0 )
    , rotation = 0
    , customTransformations = []
    , zIndex = 1
    , content = a
    }


{-| map the content of a entity
-}
map : (a -> b) -> Entity a -> Entity b
map fun i =
    { position = i.position
    , rotation = i.rotation
    , content = fun i.content
    , customTransformations = i.customTransformations
    , zIndex = i.zIndex
    }


{-| Attributes of a Entity
-}
toAttributes : Entity a -> ( a, List (Attribute msg) )
toAttributes entity =
    ( entity.content
    , [ [ move entity.position
        , rotate entity.rotation
        ]
            ++ entity.customTransformations
            |> transform
      , Html.Attributes.style "z-index" (String.fromInt entity.zIndex)
      ]
    )


{-| turn the entity into html
-}
toHtml : List (Attribute msg) -> Entity (List (Attribute msg) -> Html msg) -> Html msg
toHtml attrs entity =
    entity.content (Tuple.second (toAttributes entity) ++ attrs)


{-| map rotation
-}
mapRotation : (Float -> Float) -> Entity a -> Entity a
mapRotation fun entity =
    { entity | rotation = fun entity.rotation }


{-| map position
-}
mapPosition : (( Float, Float ) -> ( Float, Float )) -> Entity a -> Entity a
mapPosition fun entity =
    { entity | position = fun entity.position }


{-| map z-index
-}
mapZIndex : (Int -> Int) -> Entity a -> Entity a
mapZIndex fun entity =
    { entity | zIndex = fun entity.zIndex }


{-| map custom transformations
-}
mapCustomTransformations : (List Transformation -> List Transformation) -> Entity a -> Entity a
mapCustomTransformations fun entity =
    { entity | customTransformations = fun entity.customTransformations }


{-| Create an entity that can be flipped
-}
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
            |> toHtml [ Html.Attributes.style "position" "absolute" ]
        , args.back
            |> mapCustomTransformations ((::) (flip pi))
            |> toHtml [ Html.Attributes.style "position" "absolute" ]
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
        |> mapCustomTransformations
            ((++)
                (if not args.faceUp then
                    [ flip pi ]

                 else
                    [ flip 0 ]
                )
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


{-| activates a 3d-effect for the child notes. Should be used in combination with `flip`
-}
perspective : Attribute msg
perspective =
    Html.Attributes.style "perspective" "1000px"
