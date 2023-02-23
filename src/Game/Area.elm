module Game.Area exposing (..)

import Game.Entity exposing (Entity)
import Html exposing (Attribute, Html)
import Html.Attributes
import Html.Events
import Html.Keyed


type alias AreaEntity msg =
    ( String, Entity (List (Attribute msg) -> Html msg) )


new : ( Float, Float ) -> List ( String, List (Attribute msg) -> Html msg ) -> List (AreaEntity msg)
new offset =
    List.map
        (\( id, content ) ->
            ( id
            , Game.Entity.new content
                |> Game.Entity.withPosition offset
            )
        )


fromStack :
    ( Float, Float )
    ->
        { view : Int -> a -> ( String, List (Attribute msg) -> Html msg )
        , empty : ( String, List (Attribute msg) -> Html msg )
        }
    -> List (Entity a)
    -> List (AreaEntity msg)
fromStack ( x, y ) args list =
    (args.empty |> List.singleton |> new ( x, y ))
        ++ (list
                |> List.indexedMap
                    (\i stackItem ->
                        args.view i stackItem.content
                            |> (\( id, content ) ->
                                    ( id
                                    , { content = content
                                      , position = stackItem.position |> Tuple.mapBoth ((+) x) ((+) y)
                                      , rotation = stackItem.rotation
                                      , zIndex = stackItem.zIndex + i + 1
                                      , customTransformations = []
                                      }
                                    )
                               )
                    )
           )


toHtml : List (Attribute msg) -> List (AreaEntity msg) -> Html msg
toHtml attr list =
    list
        |> List.sortBy Tuple.first
        |> List.map
            (Tuple.mapSecond
                (\entity ->
                    entity.content
                        ([ Html.Attributes.style "position" "absolute"
                         , Html.Attributes.style "transition" "transform 0.5s"
                         ]
                            ++ Game.Entity.attributes entity
                        )
                )
            )
        |> Html.Keyed.node "div"
            ([ Html.Attributes.style "display" "flex"
             , Html.Attributes.style "position" "relative"
             ]
                ++ attr
            )


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
