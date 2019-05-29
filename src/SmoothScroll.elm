module SmoothScroll exposing
    ( Config
    , defaultConfig
    , scrollTo
    )

import Browser.Dom
import Ease exposing (Easing)
import Internal.SmoothScroll exposing (step)
import Task exposing (Task)
import Time


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
