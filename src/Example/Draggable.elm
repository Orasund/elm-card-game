module Example.Draggable exposing (..)

import Html exposing (Html)
import View.Area


type alias Model =
    { at : Int
    , selected : Bool
    }


init : Model
init =
    { at = 0, selected = False }


view : Model -> Html Model
view model =
    View.Area.draggable
        { onPress =
            \int ->
                model
                    |> (\s ->
                            if s.at == int && not s.selected then
                                { s | selected = True }
                                    |> Just

                            else
                                Nothing
                       )
        , onRelease =
            \int ->
                model
                    |> (\s ->
                            if s.selected then
                                { s | at = int, selected = False }
                                    |> Just

                            else
                                Nothing
                       )
        , cardAt = model.at
        , isSelected = model.selected
        }
