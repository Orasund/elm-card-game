module Game.Pile exposing (..)

import Game.Entity exposing (Entity)
import Html exposing (Attribute, Html)
import Html.Attributes
import Random exposing (Generator)


randomRotation :
    { min : Float, max : Float }
    -> Generator (Int -> a -> { movement : ( Float, Float ), rotation : Float })
randomRotation args =
    Random.map
        (\rotation _ _ ->
            { movement = ( 0, 0 ), rotation = rotation }
        )
        (Random.float args.min args.max)


randomMovement :
    { minAngle : Float, maxAngle : Float, minDistance : Float, maxDistance : Float }
    -> Generator (Int -> a -> { movement : ( Float, Float ), rotation : Float })
randomMovement args =
    Random.map2
        (\rotation distance _ _ ->
            { movement = fromPolar ( distance, rotation ), rotation = rotation }
        )
        (Random.float args.minAngle args.maxAngle)
        (Random.float args.minDistance args.maxDistance)


generate :
    Generator (Int -> a -> { movement : ( Float, Float ), rotation : Float })
    -> List a
    -> Generator (List (Entity a))
generate fun list =
    Random.list (List.length list)
        fun
        |> Random.map
            (\randomList ->
                randomList
                    |> List.map2 Tuple.pair list
                    |> List.indexedMap
                        (\i ( a, f ) ->
                            f i a
                                |> Tuple.pair a
                        )
            )
        |> Random.map
            (List.indexedMap
                (\i ( a, args ) ->
                    Game.Entity.new a
                        |> Game.Entity.withZIndex (i + 1)
                        |> Game.Entity.withPosition args.movement
                        |> Game.Entity.withRotation args.rotation
                )
            )


map : (Int -> a -> b) -> List (Entity a) -> List (Entity b)
map fun =
    List.indexedMap (\i -> Game.Entity.map (fun i))


mapPosition : (Int -> ( Float, Float ) -> ( Float, Float )) -> List (Entity a) -> List (Entity a)
mapPosition fun =
    List.indexedMap (\i -> Game.Entity.mapPosition (fun i))


mapRotation : (Int -> Float -> Float) -> List (Entity a) -> List (Entity a)
mapRotation fun =
    List.indexedMap (\i -> Game.Entity.mapRotation (fun i))


mapZIndex : (Int -> Int -> Int) -> List (Entity a) -> List (Entity a)
mapZIndex fun =
    List.indexedMap (\i -> Game.Entity.mapZIndex (fun i))


withDependentRotation : (Int -> a -> Float) -> List (Entity a) -> List (Entity a)
withDependentRotation fun =
    List.indexedMap (\i entity -> entity |> Game.Entity.withRotation (fun i entity.content))


withDependentMovement : (Int -> a -> ( Float, Float )) -> List (Entity a) -> List (Entity a)
withDependentMovement fun =
    List.indexedMap (\i entity -> entity |> Game.Entity.withPosition (fun i entity.content))


withRotation : { min : Float, max : Float } -> List (Entity a) -> List (Entity a)
withRotation args list =
    withDependentRotation
        (\i _ ->
            args.min + toFloat i * (args.max - args.min) / toFloat (List.length list - 1)
        )
        list


withMovement : { minAngle : Float, maxAngle : Float, minDistance : Float, maxDistance : Float } -> List (Entity a) -> List (Entity a)
withMovement args list =
    withDependentMovement
        (\i _ ->
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
