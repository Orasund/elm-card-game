module Chapter.Area exposing (..)

import Dict exposing (Dict)
import ElmBook.Actions
import ElmBook.Chapter exposing (Chapter)
import Game.Area
import Html exposing (Html)
import Html.Attributes
import View.Area


type alias AreaId =
    { areaId : Int }


type alias CardId =
    { cardId : Int }


type alias Card =
    {}


type alias HoverState =
    Maybe Int


type alias DraggableState =
    { at : Int
    , selected : Bool
    }


type alias State =
    { cards : Dict Int Card
    , areas : Dict Int (List CardId)
    , dragging :
        Maybe
            { cardId : CardId
            , fromArea : AreaId
            , aboveArea : AreaId
            }
    , hoverState : HoverState
    , draggableState : DraggableState
    }


type Msg
    = StartDragging AreaId
    | DraggedOnto AreaId
    | DragIn AreaId
    | DragOut
    | StopDragging
    | HoverStateSet (Maybe Int)
    | DraggableStateSet DraggableState


init : State
init =
    { cards =
        List.repeat 3 {}
            |> List.indexedMap Tuple.pair
            |> Dict.fromList
    , areas =
        Dict.fromList
            [ ( 0, List.range 0 4 |> List.map CardId ) ]
    , dragging = Nothing
    , hoverState = Nothing
    , draggableState = { at = 0, selected = False }
    }


update : Msg -> State -> State
update msg state =
    case msg of
        StartDragging areaId ->
            { state
                | dragging =
                    state.areas
                        |> Dict.get areaId.areaId
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
            { state | dragging = Nothing }

        DraggedOnto id ->
            state.dragging
                |> Maybe.map
                    (\{ cardId, fromArea } ->
                        { state
                            | dragging = Nothing
                            , areas =
                                state.areas
                                    |> Dict.update fromArea.areaId
                                        (\maybe ->
                                            maybe
                                                |> Maybe.map (List.filter ((/=) cardId))
                                        )
                                    |> Dict.update id.areaId
                                        (\maybe ->
                                            maybe
                                                |> Maybe.withDefault []
                                                |> (::) cardId
                                                |> Just
                                        )
                        }
                    )
                |> Maybe.withDefault state

        DragIn areaId ->
            { state
                | dragging =
                    state.dragging
                        |> Maybe.map (\dragging -> { dragging | aboveArea = areaId })
            }

        DragOut ->
            { state
                | dragging =
                    state.dragging
                        |> Maybe.map (\dragging -> { dragging | aboveArea = dragging.fromArea })
            }

        HoverStateSet maybe ->
            { state | hoverState = maybe }

        DraggableStateSet int ->
            { state | draggableState = int }


pile : State -> Html Msg
pile state =
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
                                    |> Dict.get cardId.cardId
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
                                    if dragging.aboveArea == AreaId i then
                                        state.cards
                                            |> Dict.get dragging.cardId.cardId
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
                                StartDragging (AreaId i) |> Just
                        , onStopDragging =
                            if draggedFromArea == Just (AreaId i) then
                                StopDragging |> Just

                            else
                                DraggedOnto (AreaId i) |> Just
                        , onEntering =
                            draggedFromArea
                                |> Maybe.andThen
                                    (\_ ->
                                        Just (DragIn (AreaId i))
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


chapter : { get : model -> State, setTo : model -> State -> model } -> Chapter model
chapter args =
    ElmBook.Chapter.chapter "Game.Area"
        |> ElmBook.Chapter.withChapterInit
            (\state ->
                ( args.setTo state init, Cmd.none )
            )
        |> ElmBook.Chapter.renderStatefulComponentList
            ([ ( "hoverable"
               , \state ->
                    View.Area.hoverable
                        { onEnter = \int -> HoverStateSet (Just int)
                        , onLeave = HoverStateSet Nothing
                        , hoverOver = state.hoverState
                        }
               )
             , ( "draggable"
               , \state ->
                    View.Area.draggable
                        { onPress =
                            \int ->
                                state.draggableState
                                    |> (\s ->
                                            if s.at == int && not s.selected then
                                                { s | selected = True }
                                                    |> DraggableStateSet
                                                    |> Just

                                            else
                                                Nothing
                                       )
                        , onRelease =
                            \int ->
                                state.draggableState
                                    |> (\s ->
                                            if s.selected then
                                                { s | at = int, selected = False }
                                                    |> DraggableStateSet
                                                    |> Just

                                            else
                                                Nothing
                                       )
                        , cardAt = state.draggableState.at
                        , isSelected = state.draggableState.selected
                        }
               )
             , ( "fromStack"
               , pile
               )
             ]
                |> List.map
                    (Tuple.mapSecond
                        (\fun ->
                            \m ->
                                m
                                    |> args.get
                                    |> fun
                                    |> Html.map
                                        (\msg ->
                                            ElmBook.Actions.updateState
                                                (\model ->
                                                    model
                                                        |> args.get
                                                        |> update msg
                                                        |> args.setTo model
                                                )
                                        )
                        )
                    )
            )
