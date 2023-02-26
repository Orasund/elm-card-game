module Game.Area exposing
    ( new, toHtml
    , map, mapPosition, mapPositionRandomly, mapRotation, mapRotationRandomly, mapZIndex
    , draggable, hoverable
    , pileAbove, withLinearRotation, withPolarPosition
    )

{-|

@docs new, move, rotate, toHtml

@docs map, mapPosition, mapPositionRandomly, mapRotation, mapRotationRandomly, mapZIndex

@docs draggable, hoverable


# Piles

@docs pileAbove, withLinearRotation, withPolarPosition

-}

import Game.Entity exposing (Entity)
import Html exposing (Attribute, Html)
import Html.Attributes
import Html.Events
import Html.Keyed
import Random exposing (Generator)


{-| create a new entity in an area using a position and a key(string).
-}
new : ( Float, Float ) -> List ( String, List (Attribute msg) -> Html msg ) -> List (Entity ( String, List (Attribute msg) -> Html msg ))
new offset =
    List.map
        (\( id, content ) ->
            Game.Entity.new content
                |> Game.Entity.map (Tuple.pair id)
                |> Game.Entity.mapPosition (\_ -> offset)
        )


{-| Create a pile in an area.
-}
pileAbove :
    ( Float, Float )
    -> ( String, List (Attribute msg) -> Html msg )
    -> List (Entity ( String, List (Attribute msg) -> Html msg ))
    -> List (Entity ( String, List (Attribute msg) -> Html msg ))
pileAbove ( x, y ) empty list =
    (empty |> List.singleton |> new ( x, y ))
        ++ (list
                |> List.indexedMap
                    (\i entity ->
                        entity
                            |> Game.Entity.mapPosition (Tuple.mapBoth ((+) x) ((+) y))
                            |> Game.Entity.mapZIndex ((+) (i + 1))
                    )
           )


{-| Turn the area into Html. Animation can only happen within an area. If an entity should move from one area into another, you have to use `pileAbove` to define the sub-areas.

You can change the transition speed:

    speedInSec =
        0.5

    toHtml [Html.Attributes.style "transition" ("transform " ++ String.fromInt speedInSec ++ "s")]

-}
toHtml : List (Attribute msg) -> List (Entity ( String, List (Attribute msg) -> Html msg )) -> Html msg
toHtml attr list =
    list
        |> List.sortBy (\entity -> Tuple.first entity.content)
        |> List.map
            (\entity ->
                ( Tuple.first entity.content
                , entity.content
                    |> Tuple.second
                    |> (\f ->
                            f
                                ([ Html.Attributes.style "position" "absolute"
                                 , Html.Attributes.style "transition" "transform 0.5s"
                                 ]
                                    ++ Tuple.second (Game.Entity.toAttributes entity)
                                )
                       )
                )
            )
        |> Html.Keyed.node "div"
            ([ Html.Attributes.style "display" "flex"
             , Html.Attributes.style "position" "relative"
             ]
                ++ attr
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


{-| Apply a random rotation to each element of the list.
-}
mapRotationRandomly : (Int -> a -> Float -> Generator Float) -> List (Entity a) -> Generator (List (Entity a))
mapRotationRandomly fun list =
    Random.list (List.length list) Random.independentSeed
        |> Random.map
            (\randomList ->
                List.map2 Tuple.pair
                    list
                    randomList
                    |> List.indexedMap
                        (\i ( entity, seed ) ->
                            Random.step (fun i entity.content entity.rotation) seed
                                |> (\( rotation, _ ) -> { entity | rotation = rotation })
                        )
            )


{-| Move each element of the list to a random position.
-}
mapPositionRandomly : (Int -> a -> ( Float, Float ) -> Generator ( Float, Float )) -> List (Entity a) -> Generator (List (Entity a))
mapPositionRandomly fun list =
    Random.list (List.length list) Random.independentSeed
        |> Random.map
            (\randomList ->
                List.map2 Tuple.pair
                    list
                    randomList
                    |> List.indexedMap
                        (\i ( entity, seed ) ->
                            Random.step (fun i entity.content entity.position) seed
                                |> (\( position, _ ) -> { entity | position = position })
                        )
            )


{-| Map the contents of a list of entities
-}
map : (Int -> a -> b) -> List (Entity a) -> List (Entity b)
map fun =
    List.indexedMap (\i -> Game.Entity.map (fun i))


{-| Map the position of each entity in a list
-}
mapPosition : (Int -> a -> ( Float, Float ) -> ( Float, Float )) -> List (Entity a) -> List (Entity a)
mapPosition fun =
    List.indexedMap
        (\i entity ->
            entity |> Game.Entity.mapPosition (fun i entity.content)
        )


{-| Map the rotation of each entity in a list
-}
mapRotation : (Int -> a -> Float -> Float) -> List (Entity a) -> List (Entity a)
mapRotation fun =
    List.indexedMap
        (\i entity ->
            entity
                |> Game.Entity.mapRotation (fun i entity.content)
        )


{-| Map the z-Index of each entity in a list
-}
mapZIndex : (Int -> a -> Int -> Int) -> List (Entity a) -> List (Entity a)
mapZIndex fun =
    List.indexedMap
        (\i entity ->
            entity
                |> Game.Entity.mapZIndex (fun i entity.content)
        )


{-| rotate each element of a list evenly within a given interval.
-}
withLinearRotation : { min : Float, max : Float } -> List (Entity a) -> List (Entity a)
withLinearRotation args list =
    mapRotation
        (\i _ _ ->
            if List.length list == 1 then
                args.min + (args.max - args.min) / 2

            else
                args.min + toFloat i * (args.max - args.min) / toFloat (List.length list - 1)
        )
        list


{-| move each element in a list evenly with respect to angle and distance of the original position.
-}
withPolarPosition : { minAngle : Float, maxAngle : Float, minDistance : Float, maxDistance : Float } -> List (Entity a) -> List (Entity a)
withPolarPosition args list =
    mapPosition
        (\i _ _ ->
            if List.length list == 1 then
                ( args.minDistance + (args.maxDistance - args.minDistance) / 2
                , args.minAngle + (args.maxAngle - args.minAngle) / 2
                )
                    |> fromPolar

            else
                ( args.minDistance + toFloat i * (args.maxDistance - args.minDistance) / toFloat (List.length list - 1)
                , args.minAngle + toFloat i * (args.maxAngle - args.minAngle) / toFloat (List.length list - 1)
                )
                    |> fromPolar
        )
        list
