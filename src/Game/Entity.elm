module Game.Entity exposing
    ( Entity, new, toAttributes
    , move, rotate
    , mapCustomTransformations, mapPosition, mapRotation, mapZIndex
    , flippable, perspective
    , Transformation, transform, scale, moveTransformation, rotateTransformation, flipTransformation
    , asStack, asStackItems, draggable, group, hoverable, moveEvenlyAroundCenter, rotateEvenly, transition
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
import Html.Events


{-| A entity allows for different relative transformations like rotating or moving by a relative amount.
-}
type alias Entity =
    { position : ( Float, Float )
    , rotation : Float
    , customTransformations : List Transformation
    , zIndex : Int
    }


{-| construct a entity
-}
new : Entity
new =
    { position = ( 0, 0 )
    , rotation = 0
    , customTransformations = []

    -- cards should have at least a z-index of 1
    , zIndex = 1
    }


{-| Attributes of a Entity
-}
toAttributes : Entity -> List (Attribute msg)
toAttributes entity =
    [ [ moveTransformation entity.position
      , rotateTransformation entity.rotation
      ]
        ++ entity.customTransformations
        |> transform
    , Html.Attributes.style "z-index" (String.fromInt entity.zIndex)
    ]


{-| map rotation
-}
mapRotation : (Float -> Float) -> Entity -> Entity
mapRotation fun entity =
    { entity | rotation = fun entity.rotation }


{-| map position
-}
mapPosition : (( Float, Float ) -> ( Float, Float )) -> Entity -> Entity
mapPosition fun entity =
    { entity | position = fun entity.position }


{-| rotate a entity
-}
rotate : Float -> Entity -> Entity
rotate amount =
    mapRotation ((+) amount)


{-| move a entity
-}
move : ( Float, Float ) -> Entity -> Entity
move ( x, y ) =
    mapPosition (Tuple.mapBoth ((+) x) ((+) y))


{-| map z-index
-}
mapZIndex : (Int -> Int) -> Entity -> Entity
mapZIndex fun entity =
    { entity | zIndex = fun entity.zIndex }


{-| map custom transformations
-}
mapCustomTransformations : (List Transformation -> List Transformation) -> Entity -> Entity
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
        { front : List (Attribute msg) -> Html msg
        , back : List (Attribute msg) -> Html msg
        , faceUp : Bool
        }
    -> Entity
    -> Html msg
flippable attrs args entity =
    [ args.front
        (entity
            |> mapCustomTransformations ((::) (flipTransformation 0))
            |> toAttributes
            |> (++) [ Html.Attributes.style "position" "absolute" ]
        )

    -- place behind the front element
    , args.back
        (entity
            |> mapCustomTransformations ((::) (flipTransformation pi))
            |> toAttributes
            |> (++) [ Html.Attributes.style "position" "absolute" ]
        )
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
                ++ attrs
                ++ (entity
                        |> mapCustomTransformations
                            ((++)
                                (if not args.faceUp then
                                    [ flipTransformation pi ]

                                 else
                                    [ flipTransformation 0 ]
                                )
                            )
                        |> toAttributes
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


{-| Add transitions

    animate =
        Html.Attributes.style "transition" "transform 0.5s"

-}
transition : Attribute msg
transition =
    Html.Attributes.style "transition" "transform 0.5s"


{-| Turn elements into a stack item

    asStackItems =
        Html.Attributes.style "position" "absolute"

-}
asStackItems : Attribute msg
asStackItems =
    Html.Attributes.style "position" "absolute"


{-| Turn child elements into a stack

    asStack =
        Html.Attributes.style "position" "relative"

-}
asStack : Attribute msg
asStack =
    Html.Attributes.style "position" "relative"


{-| Create a pile in an area.
-}
group : ( Float, Float ) -> List Entity -> List Entity
group ( x, y ) list =
    list
        |> List.indexedMap
            (\i entity ->
                entity
                    |> mapPosition (Tuple.mapBoth ((+) x) ((+) y))
                    |> mapZIndex ((+) (i + 1))
            )


{-| Define hover events
-}
hoverable : { onEnter : Maybe msg, onLeave : Maybe msg } -> List (Attribute msg)
hoverable args =
    [ args.onEnter |> Maybe.map Html.Events.onMouseEnter
    , args.onLeave |> Maybe.map Html.Events.onMouseLeave
    ]
        |> List.filterMap identity


{-| assigns three events: onMouseUp, onMouseDown and onClick (useful for touch screens).

onClick will perform the onPress action and if that does not exist, it will perform the onRelease action instead.

-}
draggable : { onPress : Maybe msg, onRelease : Maybe msg } -> List (Attribute msg)
draggable args =
    [ Html.Attributes.style "user-select" "none" |> Just
    , args.onRelease |> Maybe.map Html.Events.onMouseUp
    , args.onPress |> Maybe.map Html.Events.onMouseDown
    , (case args.onPress of
        Just a ->
            Just a

        Nothing ->
            args.onRelease
      )
        |> Maybe.map Html.Events.onClick
    ]
        |> List.filterMap identity


{-| rotate each element of a list evenly within a given interval.
-}
rotateEvenly :
    { min : Float
    , max : Float
    , index : Int
    , length : Int
    }
    -> Entity
    -> Entity
rotateEvenly args =
    rotate
        (if args.length == 1 then
            args.min + (args.max - args.min) / 2

         else
            args.min + toFloat args.index * (args.max - args.min) / toFloat (args.length - 1)
        )


{-| Useful to fan out the elements
-}
moveEvenlyAroundCenter :
    { minAngle : Float
    , maxAngle : Float
    , minDistance : Float
    , maxDistance : Float
    , index : Int
    , length : Int
    }
    -> Entity
    -> Entity
moveEvenlyAroundCenter args =
    move
        (if args.length == 1 then
            ( args.minDistance + (args.maxDistance - args.minDistance) / 2
            , args.minAngle + (args.maxAngle - args.minAngle) / 2
            )
                |> fromPolar

         else
            ( args.minDistance + toFloat args.index * (args.maxDistance - args.minDistance) / toFloat (args.length - 1)
            , args.minAngle + toFloat args.index * (args.maxAngle - args.minAngle) / toFloat (args.length - 1)
            )
                |> fromPolar
        )
