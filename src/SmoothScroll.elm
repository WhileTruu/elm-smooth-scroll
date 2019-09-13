module SmoothScroll exposing (Config, createConfig, scrollTo)

{-| Scrolling to position that always takes the same amount of time.

@docs Config, createConfig, scrollTo

-}

import Browser.Dom
import Ease exposing (Easing)
import Task exposing (Task)
import Time exposing (Posix)


{-| Configuration for smooth scrolling.
-}
type Config
    = Config { duration : Int, easing : Easing }


{-| Create a smooth scroll configuration from an easing function and a duration
in milliseconds.

  - easing: [Easing functions](https://package.elm-lang.org/packages/elm-community/easing-functions/latest)
    specify the rate of change of a parameter over time.

  - duration: The total duration of the scroll in milliseconds.

```
createConfig Ease.outCubic 100
```

-}
createConfig : Easing -> Int -> Config
createConfig easing duration =
    Config { duration = duration, easing = easing }


{-| Scroll to the `y` offset of the browser viewport using the easing function
and duration specified in the config.

    scrollTo (createConfig Ease.outCubic 100) 500

-}
scrollTo : Config -> Float -> Task x ()
scrollTo (Config config) y =
    Task.map2
        (\{ viewport } startTime ->
            Task.andThen
                (step (Browser.Dom.setViewport viewport.x) config viewport.y y startTime)
                Time.now
        )
        Browser.Dom.getViewport
        Time.now
        |> Task.andThen identity


{-| Change the `y` offset of the browser viewport to the calculated position and
then do that again and again until the duration is larger than the time elapsed.
-}
step :
    (Float -> Task x ())
    -> { duration : Int, easing : Easing }
    -> Float
    -> Float
    -> Posix
    -> Posix
    -> Task x ()
step setViewportY config start end startTime now =
    let
        elapsed : Int
        elapsed =
            Time.posixToMillis now - Time.posixToMillis startTime
    in
    setViewportY (position config start end elapsed)
        |> Task.andThen
            (if elapsed < config.duration then
                \_ -> Time.now |> Task.andThen (step setViewportY config start end startTime)

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
