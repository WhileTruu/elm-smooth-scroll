module Main exposing (main)

import Browser exposing (Document)
import Browser.Dom
import Dict exposing (Dict)
import Ease
import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing (alt, id, src, style)
import Html.Events exposing (onClick)
import SmoothScroll
import Task exposing (Task)
import Time


myViewportNodeId : String
myViewportNodeId =
    "mynode"


main : Platform.Program () (Maybe Time.Posix) Msg
main =
    Browser.document
        { init = \_ -> ( Nothing, Task.perform GotPosixTime Time.now )
        , view =
            Maybe.map view
                >> Maybe.withDefault { title = "⏳", body = [] }
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = GotPosixTime Time.Posix
    | ClickedScrollToTop
    | ClickedScrollToBottom
    | ClickedScrollToFifthCatImage
    | NoOp


scrollTo : Float -> Task Browser.Dom.Error ()
scrollTo =
    SmoothScroll.scrollToOf
        (SmoothScroll.createConfig Ease.inOutQuint 500)
        myViewportNodeId


scrollToTop : Cmd Msg
scrollToTop =
    Task.attempt (always NoOp) (scrollTo 0)


scrollToBottom : Cmd Msg
scrollToBottom =
    Task.attempt (always NoOp)
        (Browser.Dom.getViewportOf myViewportNodeId
            |> Task.andThen
                (\{ scene, viewport } -> scrollTo (scene.height - viewport.height))
        )


scrollToElement : String -> Cmd Msg
scrollToElement id =
    Task.attempt (always NoOp)
        (getElementOf { viewportId = myViewportNodeId, elementId = id }
            |> Task.andThen (scrollTo << .y << .element)
        )


getElementOf :
    { viewportId : String, elementId : String }
    -> Task Browser.Dom.Error Browser.Dom.Element
getElementOf { viewportId, elementId } =
    Task.map3
        (\e v ev ->
            { scene = v.scene
            , viewport = v.viewport
            , element =
                e.element
                    |> (\a ->
                            { a
                                | x = a.x - ev.element.x
                                , y = a.y - ev.element.y + v.viewport.y
                            }
                       )
            }
        )
        (Browser.Dom.getElement elementId)
        (Browser.Dom.getViewportOf viewportId)
        (Browser.Dom.getElement viewportId)


update : Msg -> Maybe Time.Posix -> ( Maybe Time.Posix, Cmd Msg )
update msg maybePosixTime =
    case msg of
        NoOp ->
            ( maybePosixTime, Cmd.none )

        GotPosixTime posixTime ->
            ( Just posixTime, Cmd.none )

        ClickedScrollToTop ->
            ( maybePosixTime, scrollToTop )

        ClickedScrollToBottom ->
            ( maybePosixTime, scrollToBottom )

        ClickedScrollToFifthCatImage ->
            ( maybePosixTime, scrollToElement "cat5" )


view : Time.Posix -> Document Msg
view posixTime =
    { title = "Example"
    , body =
        [ div []
            [ button [ onClick ClickedScrollToBottom ] [ text "Scroll to bottom!" ]
            , button [ onClick ClickedScrollToFifthCatImage ]
                [ text "Take me to the fifth cat!" ]
            , myViewportNode (catImages posixTime)
            , button [ onClick ClickedScrollToTop ] [ text "Scroll to top!" ]
            ]
        ]
    }


myViewportNode : List (Html msg) -> Html msg
myViewportNode =
    div
        [ id myViewportNodeId
        , style "height" "500px"
        , style "backgroundColor" "tomato"
        , style "overflow" "scroll"
        ]


catImage : Int -> Time.Posix -> Html msg
catImage i posixTime =
    img
        [ src ("https://cataas.com/cat?time=" ++ String.fromInt (Time.posixToMillis posixTime + i))
        , alt <| "Cat " ++ String.fromInt i
        , id <| "cat" ++ String.fromInt i
        ]
        []


catImages : Time.Posix -> List (Html msg)
catImages posixTime =
    List.map (\i -> div [] [ catImage i posixTime ]) (List.range 1 10)
