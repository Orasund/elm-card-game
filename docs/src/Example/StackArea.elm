module Example.StackArea exposing (..)

import Dict exposing (Dict)
import Game.Area
import Html exposing (Html)
import Html.Attributes
import View.Area


type alias AreaId =
    Int


type alias CardId =
    Int


type alias Card =
    {}


type alias Model =
    { cards : Dict Int Card
    , areas : Dict Int (List CardId)
    , dragging :
        Maybe
            { cardId : CardId
            , fromArea : AreaId
            , aboveArea : AreaId
            }
    }


type Msg
    = StartDragging AreaId
    | DraggedOnto AreaId
    | DragIn AreaId
    | DragOut
    | StopDragging


init : Model
init =
    { cards =
        List.repeat 3 {}
            |> List.indexedMap Tuple.pair
            |> Dict.fromList
    , areas =
        Dict.fromList
            [ ( 0, List.range 0 4 ) ]
    , dragging = Nothing
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        StartDragging areaId ->
            { model
                | dragging =
                    model.areas
                        |> Dict.get areaId
                        |> Maybe.andThen List.head
                        |> Maybe.map
                            (\cardId ->
                                { fromArea = areaId
                                , cardId = cardId
                                , aboveArea = areaId
                                }
                            )
            }

        StopDragging ->
            { model | dragging = Nothing }

        DraggedOnto id ->
            model.dragging
                |> Maybe.map
                    (\{ cardId, fromArea } ->
                        { model
                            | dragging = Nothing
                            , areas =
                                model.areas
                                    |> Dict.update fromArea
                                        (\maybe ->
                                            maybe
                                                |> Maybe.map (List.filter ((/=) cardId))
                                        )
                                    |> Dict.update id
                                        (\maybe ->
                                            maybe
                                                |> Maybe.withDefault []
                                                |> (::) cardId
                                                |> Just
                                        )
                        }
                    )
                |> Maybe.withDefault model

        DragIn areaId ->
            { model
                | dragging =
                    model.dragging
                        |> Maybe.map (\dragging -> { dragging | aboveArea = areaId })
            }

        DragOut ->
            { model
                | dragging =
                    model.dragging
                        |> Maybe.map (\dragging -> { dragging | aboveArea = dragging.fromArea })
            }


view : Model -> Html Msg
view state =
    let
        draggedFromArea =
            state.dragging
                |> Maybe.map .fromArea
    in
    List.repeat 3 ()
        |> List.indexedMap (\i () -> state.areas |> Dict.get i |> Maybe.withDefault [])
        |> List.indexedMap
            (\i list ->
                list
                    |> List.filterMap
                        (\cardId ->
                            if
                                state.dragging
                                    |> Maybe.map .cardId
                                    |> Maybe.map ((==) cardId)
                                    |> Maybe.withDefault False
                            then
                                Nothing

                            else
                                state.cards
                                    |> Dict.get cardId
                                    |> Maybe.map
                                        (\card ->
                                            { cardId = cardId
                                            , card = card
                                            , asPhantom = False
                                            }
                                        )
                        )
                    |> (state.dragging
                            |> Maybe.map
                                (\dragging ->
                                    if dragging.aboveArea == i then
                                        state.cards
                                            |> Dict.get dragging.cardId
                                            |> Maybe.map
                                                (\card ->
                                                    (::)
                                                        { cardId = dragging.cardId
                                                        , card = card
                                                        , asPhantom = True
                                                        }
                                                )
                                            |> Maybe.withDefault identity

                                    else
                                        identity
                                )
                            |> Maybe.withDefault identity
                       )
                    |> View.Area.pile i
                        { position = ( toFloat i * 150, 0 )
                        , onStartDragging =
                            if draggedFromArea /= Nothing then
                                Nothing

                            else
                                StartDragging i |> Just
                        , onStopDragging =
                            if draggedFromArea == Just i then
                                StopDragging |> Just

                            else
                                DraggedOnto i |> Just
                        , onEntering =
                            draggedFromArea
                                |> Maybe.andThen
                                    (\_ ->
                                        Just (DragIn i)
                                    )
                        , onLeaving =
                            draggedFromArea
                                |> Maybe.andThen
                                    (\_ ->
                                        Just DragOut
                                    )
                        }
            )
        |> List.concat
        |> Game.Area.toHtml
            [ Html.Attributes.style "height" "200px"
            ]
