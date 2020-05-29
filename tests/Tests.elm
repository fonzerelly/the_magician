module Tests exposing (..)

import Test exposing (..)
import Expect
import Cards exposing (faceName, Face (..))


-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!


all : Test
all =
    describe "A Test Suite"
        [ test "Addition" <|
            \_ ->
                Expect.equal 10 (3 + 7)
        , test "String.left" <|
            \_ ->
                Expect.equal "a" (String.left 1 "abcdefg")
        , test "faceName should turn Ace to 'A'" <|
            \_ ->
                faceName Ace |> Expect.equal "A" 
        , test "faceName should turn King to 'K'" <|
            \_ ->
                faceName King |> Expect.equal "K"
        , test "faceName should turn Queen to 'Q'" <|
            \_ ->
                faceName Queen |> Expect.equal "Q"
        , test "faceName should turn Jack to 'J'" <|
            \_ ->
                faceName Jack |> Expect.equal "J"
        , test "faceName should turn Ten to '10'" <|
            \_ ->
                faceName Ten |> Expect.equal "10"
        , test "faceName should turn Nine to '9'" <|
            \_ ->
                faceName Nine |> Expect.equal "9"
        , test "faceName should turn Eight to '8'" <|
            \_ ->
                faceName Eight |> Expect.equal "8"
        , test "faceName should turn Seven to '7'" <|
            \_ ->
                faceName Seven |> Expect.equal "7"
        , test "faceName should turn Six to '6'" <|
            \_ ->
                faceName Six |> Expect.equal "6"
        , test "faceName should turn Five to '5'" <|
            \_ ->
                faceName Five |> Expect.equal "5"
        , test "faceName should turn Four to '4'" <|
            \_ ->
                faceName Four |> Expect.equal "4"
        , test "faceName should turn Three to '3'" <|
            \_ ->
                faceName Three |> Expect.equal "3"
        , test "faceName should turn Two to '2'" <|
            \_ ->
                faceName Two |> Expect.equal "2"
        ]
