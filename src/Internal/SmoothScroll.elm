module Internal.SmoothScroll exposing (step)

import Browser.Dom
import Ease exposing (Easing)
import Task exposing (Task)
import Time exposing (Posix)


{-| Change the `y` offset of the browser viewport to the calculated position and
then do that again and again until the duration is larger than the time elapsed.
-}
step : { duration : Int, easing : Easing } -> Float -> Float -> Posix -> Posix -> Task x ()
step config start end startTime now =
    let
        elapsed : Int
        elapsed =
            Time.posixToMillis now - Time.posixToMillis startTime
    in
    Browser.Dom.setViewport 0 (position config start end elapsed)
        |> Task.andThen
            (if elapsed < config.duration then
                \_ -> Time.now |> Task.andThen (step config start end startTime)

             else
                Task.succeed
            )


{-| Calculate the desired scroll position.

    position defaultConfig 450 0 225 == 225

-}
position : { duration : Int, easing : Easing } -> Float -> Float -> Int -> Float
position { easing, duration } start end elapsed =
    if elapsed < duration then
        start + (end - start) * easing (toFloat elapsed / toFloat duration)

    else
        end
