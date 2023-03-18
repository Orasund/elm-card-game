# elm-card-game

Elm-Card-Game is a package for displaying card games. Checkout the [guide](https://orasund.github.io/elm-card-game) and the [demo project](https://orasund.github.io/elm-card-game/#/demo/rock-paper-scissors).

* **Cards** are styled `div` nodes that take use of Flexbox.
* **Entities** are an abstraction of CSS-Transformations. You can move and rotate entities, pile them together and apply transformations to piles of entities.
* A **Area** should be something you can interact with. It uses `Html.Keyed` to allow for transitions between states.

## Install

```
elm install Orasund/elm-card-game
```

## Games created with elm-card-game

* [Waiting for Wind](https://orasund.itch.io/waiting-for-wind)
* [Enough for Now](https://orasund.itch.io/enough-for-now)

## No Magic Included

The mechanics behind this package are actually quite boring. No wizardry was used.

Please feel free to look at the source code. We tried to make the code as understandable as possible.

While developing this package we sticked to the following rules:

* We always used `height` and `aspect-ratio` instead of using `weight`.
* We used `rgba(0, 0, 0, 0.2)` as a placeholder for color.
* Every node uses Flexbox.
* All stylings are intended to be overwritten.
* Cards have a minimum z-Index of 1