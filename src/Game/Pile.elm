module Game.Pile exposing (..)

import Game.Entity exposing (Entity)
import Html exposing (Attribute, Html)
import Html.Attributes
import Random exposing (Generator)


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


map : (Int -> a -> b) -> List (Entity a) -> List (Entity b)
map fun =
    List.indexedMap (\i -> Game.Entity.map (fun i))


mapPosition : (Int -> a -> ( Float, Float ) -> ( Float, Float )) -> List (Entity a) -> List (Entity a)
mapPosition fun =
    List.indexedMap
        (\i entity ->
            entity |> Game.Entity.mapPosition (fun i entity.content)
        )


mapRotation : (Int -> a -> Float -> Float) -> List (Entity a) -> List (Entity a)
mapRotation fun =
    List.indexedMap
        (\i entity ->
            entity
                |> Game.Entity.mapRotation (fun i entity.content)
        )


mapZIndex : (Int -> a -> Int -> Int) -> List (Entity a) -> List (Entity a)
mapZIndex fun =
    List.indexedMap
        (\i entity ->
            entity
                |> Game.Entity.mapZIndex (fun i entity.content)
        )


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


toHtml :
    List (Attribute msg)
    ->
        { view : Int -> a -> List (Attribute msg) -> Html msg
        , empty : Html msg
        }
    -> List (Entity a)
    -> Html msg
toHtml attrs { view, empty } stack =
    stack
        |> List.indexedMap
            (\i ->
                Game.Entity.toHtml
                    [ Html.Attributes.style "position" "absolute"
                    ]
                    (view i)
            )
        |> (::) empty
        |> Html.div
            ([ Html.Attributes.style "display" "flex"
             , Html.Attributes.style "position" "relative"
             ]
                ++ attrs
            )
