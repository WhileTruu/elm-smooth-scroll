module Main exposing (main)

import Browser exposing (Document)
import Browser.Dom
import Dict exposing (Dict)
import Ease
import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing (alt, id, src)
import Html.Events exposing (onClick)
import SmoothScroll
import Task exposing (Task)


main : Platform.Program () () Msg
main =
    Browser.document
        { init = \_ -> ( (), Cmd.none )
        , view = \_ -> view
        , update = \msg -> \_ -> update msg |> Tuple.pair ()
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = ScrollToTop
    | ScrollToBottom
    | ScrollToFifthCatImage
    | NoOp


scrollTo : Float -> Task x ()
scrollTo =
    SmoothScroll.scrollTo <| SmoothScroll.createConfig Ease.inOutQuint 500


scrollToTop : Cmd Msg
scrollToTop =
    Task.attempt (always NoOp) (scrollTo 0)


scrollToBottom : Cmd Msg
scrollToBottom =
    Task.attempt (always NoOp)
        (Browser.Dom.getViewport
            |> Task.andThen
                (\{ scene, viewport } -> scrollTo (scene.height - viewport.height))
        )


scrollToElement : String -> Cmd Msg
scrollToElement id =
    Task.attempt (always NoOp)
        (Browser.Dom.getElement id |> Task.andThen (scrollTo << .y << .element))


update : Msg -> Cmd Msg
update msg =
    case msg of
        NoOp ->
            Cmd.none

        ScrollToTop ->
            scrollToTop

        ScrollToBottom ->
            scrollToBottom

        ScrollToFifthCatImage ->
            scrollToElement "cat5"


view : Document Msg
view =
    { title = "Example"
    , body =
        button [ onClick ScrollToBottom ] [ text "Scroll to bottom!" ]
            :: button [ onClick ScrollToFifthCatImage ] [ text "Take me to the fifth cat!" ]
            :: catImages
            ++ [ button [ onClick ScrollToTop ] [ text "Scroll to top!" ] ]
    }


catImage : Int -> Html msg
catImage i =
    img
        [ src "https://cataas.com/cat"
        , alt <| "Cat " ++ String.fromInt i
        , id <| "cat" ++ String.fromInt i
        ]
        []


catImages : List (Html msg)
catImages =
    List.map (\i -> div [] [ catImage i ]) (List.range 1 10)
