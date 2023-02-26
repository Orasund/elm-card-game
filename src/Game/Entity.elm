module Game.Entity exposing
    ( Entity, new, toAttributes, toHtml, pileAbove
    , move, rotate
    , map, mapCustomTransformations, mapPosition, mapRotation, mapZIndex
    , flippable, perspective
    , Transformation, transform, scale, moveTransformation, rotateTransformation, flipTransformation
    )

{-| module for working with entities.


# Entity

@docs Entity, new, toAttributes, toHtml, pileAbove

@docs move, rotate

@docs map, mapCustomTransformations, mapPosition, mapRotation, mapZIndex

@docs flippable, perspective


# Transformation

@docs Transformation, transform, scale, moveTransformation, rotateTransformation, flipTransformation

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
    , content = a

    -- cards should have at least a z-index of 1
    , zIndex = 1
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
    , [ [ moveTransformation entity.position
        , rotateTransformation entity.rotation
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


{-| rotate a entity
-}
rotate : Float -> Entity a -> Entity a
rotate amount =
    mapRotation ((+) amount)


{-| move a entity
-}
move : ( Float, Float ) -> Entity a -> Entity a
move ( x, y ) =
    mapPosition (Tuple.mapBoth ((+) x) ((+) y))


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

**For technical reasons we needed to provide a width. Default is a ratio of 2/3**

You can overrule the default by providing a width:

    height = 200

    ratio = 2/3

    flippable [Html.Attributes.style "width" (String.fromFloat (height * ratio) ++ "px")]

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
            |> mapCustomTransformations ((::) (flipTransformation 0))
            |> toHtml [ Html.Attributes.style "position" "absolute" ]

        -- place behind the front element
        , args.back
            |> mapCustomTransformations ((::) (flipTransformation pi))
            |> toHtml [ Html.Attributes.style "position" "absolute" ]
        ]
            |> Html.div
                ([ Html.Attributes.style "position" "relative"
                 , Html.Attributes.style "transition" "transform 0.5s"
                 , Html.Attributes.style "height" "200px"

                 -- allow 3d rotations (flipping)
                 , Html.Attributes.style "transform-style" "preserve-3d"

                 -- width can be overwritten if your entity has different dimensions
                 -- using a ratio will not work for this implementation!
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
                    [ flipTransformation pi ]

                 else
                    [ flipTransformation 0 ]
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
rotateTransformation : Float -> Transformation
rotateTransformation float =
    "rotate("
        ++ String.fromFloat float
        ++ "rad)"


{-| Move the card
-}
moveTransformation : ( Float, Float ) -> Transformation
moveTransformation ( x, y ) =
    "translate("
        ++ String.fromFloat x
        ++ "px,"
        ++ String.fromFloat y
        ++ "px)"


{-| Flip the card. Only works if the outer div has a `perspective` Attribute
-}
flipTransformation : Float -> Transformation
flipTransformation float =
    "rotateY("
        ++ String.fromFloat float
        ++ "rad)"


{-| Activates a 3d-effect for the child notes. Should be used in combination with `flip`
-}
perspective : Attribute msg
perspective =
    Html.Attributes.style "perspective" "1000px"


{-| Group Entities into a pile
-}
pileAbove :
    Html msg
    -> List (Entity (List (Attribute msg) -> Html msg))
    -> Entity (List (Attribute msg) -> Html msg)
pileAbove empty stack =
    (\attrs ->
        stack
            |> List.map
                (toHtml
                    [ Html.Attributes.style "position" "absolute"
                    ]
                )
            |> (::) empty
            |> Html.div
                ([ Html.Attributes.style "display" "flex"
                 , Html.Attributes.style "position" "relative"
                 ]
                    ++ attrs
                )
    )
        |> new
