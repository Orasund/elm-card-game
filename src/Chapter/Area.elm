module Chapter.Area exposing (..)

import ElmBook.Actions
import ElmBook.Chapter exposing (Chapter)
import Example.Draggable
import Example.Hover
import Example.StackArea
import Html


type alias State =
    { stackAreaModel : Example.StackArea.Model
    , hoverState : Example.Hover.Model
    , draggableState : Example.Draggable.Model
    }


type Msg
    = StackAreaMsg Example.StackArea.Msg
    | HoverStateSet Example.Hover.Model
    | DraggableStateSet Example.Draggable.Model


init : State
init =
    { stackAreaModel = Example.StackArea.init
    , hoverState = Example.Hover.init
    , draggableState = Example.Draggable.init
    }


update : Msg -> State -> State
update msg state =
    case msg of
        StackAreaMsg m ->
            { state | stackAreaModel = Example.StackArea.update m state.stackAreaModel }

        HoverStateSet m ->
            { state | hoverState = m }

        DraggableStateSet m ->
            { state | draggableState = m }


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
                    state.hoverState
                        |> Example.Hover.view
                        |> Html.map HoverStateSet
               )
             , ( "draggable"
               , \state ->
                    state.draggableState
                        |> Example.Draggable.view
                        |> Html.map DraggableStateSet
               )
             , ( "fromPile"
               , \state ->
                    state.stackAreaModel
                        |> Example.StackArea.view
                        |> Html.map StackAreaMsg
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
