module ResponsiveTests exposing (..)

import Test exposing (..)
import Expect
import Responsive exposing (isMobile)


all : Test
all =
    describe "Responsive"
        [ test "375px is mobile" <|
            \_ -> isMobile 375 |> Expect.equal True

        , test "600px is not mobile" <|
            \_ -> isMobile 600 |> Expect.equal False

        , test "1024px is not mobile" <|
            \_ -> isMobile 1024 |> Expect.equal False

        , test "599px is still mobile" <|
            \_ -> isMobile 599 |> Expect.equal True
        ]
