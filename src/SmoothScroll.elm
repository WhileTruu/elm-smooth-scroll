module SmoothScroll exposing
    ( Config
    , defaultConfig
    , scrollTo
    )

import Browser.Dom
import Ease exposing (Easing)
import Internal.SmoothScroll exposing (step)
import Task exposing (Task)
import Time exposing (Posix)


{-|

  - duration: The total duration of the scroll in milliseconds.
  - easing: [Easing functions](https://package.elm-lang.org/packages/elm-community/easing-functions/latest)
    specify the rate of change of a parameter over time.

-}
type Config
    = Config { duration : Int, easing : Easing }


{-|

    defaultConfig : Config
    defaultConfig =
        { duration = 500, easing = Ease.inOutQuint }

-}
defaultConfig : Config
defaultConfig =
    Config { duration = 500, easing = Ease.inOutQuint }


{-| Create a smooth scroll configuration type.

    createConfig Ease.outCubic 100 == Config { duration = 100, easing = Ease.outCubic }

-}
createConfig : Easing -> Int -> Config
createConfig easing duration =
    Config { duration = duration, easing = easing }


{-| Scroll to the `y` offset of the browser viewport using the easing function
and duration specified in the config.
-}
scrollTo : Config -> Float -> Task x ()
scrollTo (Config config) y =
    Task.map2
        (\{ viewport } startTime ->
            Time.now |> Task.andThen (step config viewport.y y startTime)
        )
        Browser.Dom.getViewport
        Time.now
        |> Task.andThen identity


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
