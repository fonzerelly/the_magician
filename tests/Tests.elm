module Tests exposing (..)

import Test exposing (..)
import Fuzz exposing (..)
import Expect

-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!

all : Test
all =
    describe "A Test Suite"
        [ describe "dummy description"
            [ test "dummy test" <|
                \_ -> 1 +3 |>Expect.equal 4
            ]
        ]

