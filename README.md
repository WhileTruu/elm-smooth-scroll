# SmoothScroll

Scrolling to position that always takes the same amount of time.

### [Demo](https://whiletruu.github.io/elm-smooth-scroll/)

## Usage
The full working example lives in the `example` directory, which results in the demo linked above when built.

In order to scroll to the `y` offset of the browser viewport with the `scrollTo` function you first need a `Config` describing how the scrolling feels and how long it takes. A `Config` can be created using an `easing` function and a `duration`.

  - easing: [Easing functions](https://package.elm-lang.org/packages/elm-community/easing-functions/latest)
    specify the rate of change of a parameter over time.

  - duration: The total duration of the scroll in milliseconds.

```elm
config : Config
config =
    createConfig Ease.outCubic 100
```

Provided we know the `y` we want to scroll to (the top of the page or the `y` value of an element found using `Browser.Dom` package for example), scrolling is as easy as passing the position to the `scrollTo` function along with the config.

```elm
scrollTo config 500
```
