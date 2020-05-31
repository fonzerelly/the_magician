# The magician

## Prerequisites

- `npm`
- `npx`
- `elm`

Install `create-elm-app` locally:

```sh
npm install create-elm-app
```

## Test elm-app

```sh
npx elm-app start
```

Visiting [localhost:3000](http://localhost:3000) in a browser should render the app.

## Run tests

```sh
npx elm-test
```

should output something similar to:

```sh
elm-test 0.19.1-revision2
-------------------------

Running 20 tests. To reproduce these results, run: elm-test --fuzz 100 --seed 176585423615561 /home/patrick/projects/the_magician/tests/Tests.elm


TEST RUN PASSED

Duration: 191 ms
Passed:   20
Failed:   0
```
