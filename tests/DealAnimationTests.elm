module DealAnimationTests exposing (..)

import Test exposing (..)
import Expect
import DealAnimation exposing (Pile(..), dealDestination, AnimPhase(..), tick)
import Cards exposing (Card(..), Face(..), Suit(..))


all : Test
all =
    describe "DealAnimation"
        [ describe "dealDestination"
            [ test "card at index 0 goes to PileLeft" <|
                \_ -> dealDestination 0 |> Expect.equal PileLeft

            , test "card at index 1 goes to PileCenter" <|
                \_ -> dealDestination 1 |> Expect.equal PileCenter

            , test "card at index 2 goes to PileRight" <|
                \_ -> dealDestination 2 |> Expect.equal PileRight

            , test "card at index 3 goes to PileLeft again (wraps)" <|
                \_ -> dealDestination 3 |> Expect.equal PileLeft

            , test "card at index 4 goes to PileCenter again (wraps)" <|
                \_ -> dealDestination 4 |> Expect.equal PileCenter

            , test "card at index 5 goes to PileRight again (wraps)" <|
                \_ -> dealDestination 5 |> Expect.equal PileRight
            ]

        , describe "tick"
            [ test "Idle stays Idle (no cards left)" <|
                \_ ->
                    tick [] (Idle 0) |> Expect.equal (Idle 0)

            , test "Idle starts Shrinking when cards remain" <|
                \_ ->
                    let
                        cards = [ Card Spades Ace, Card Hearts King ]
                        result = tick cards (Idle 0)
                    in
                    case result of
                        Shrinking _ -> Expect.pass
                        other -> Expect.fail ("Expected Shrinking, got: " ++ Debug.toString other)

            , test "Shrinking with progress < 1 stays Shrinking" <|
                \_ ->
                    let
                        anim = { index = 0, card = Card Spades Ace, dest = PileLeft, progress = 0.5 }
                        result = tick [] (Shrinking anim)
                    in
                    case result of
                        Shrinking _ -> Expect.pass
                        other -> Expect.fail ("Expected Shrinking, got: " ++ Debug.toString other)

            , test "Shrinking with progress >= 1 transitions to Expanding" <|
                \_ ->
                    let
                        anim = { index = 0, card = Card Spades Ace, dest = PileLeft, progress = 0.95 }
                        result = tick [] (Shrinking anim)
                    in
                    case result of
                        Expanding _ -> Expect.pass
                        other -> Expect.fail ("Expected Expanding, got: " ++ Debug.toString other)

            , test "Expanding with progress < 1 stays Expanding" <|
                \_ ->
                    let
                        anim = { index = 0, card = Card Spades Ace, dest = PileLeft, progress = 0.5 }
                        result = tick [] (Expanding anim)
                    in
                    case result of
                        Expanding _ -> Expect.pass
                        other -> Expect.fail ("Expected Expanding, got: " ++ Debug.toString other)

            , test "Expanding with progress >= 1 transitions to Sliding" <|
                \_ ->
                    let
                        anim = { index = 0, card = Card Spades Ace, dest = PileLeft, progress = 0.95 }
                        result = tick [] (Expanding anim)
                    in
                    case result of
                        Sliding _ -> Expect.pass
                        other -> Expect.fail ("Expected Sliding, got: " ++ Debug.toString other)

            , test "Sliding with progress >= 1 transitions to next Idle" <|
                \_ ->
                    let
                        anim = { index = 0, card = Card Spades Ace, dest = PileLeft, progress = 0.95 }
                        result = tick [] (Sliding anim)
                    in
                    case result of
                        Idle 1 -> Expect.pass
                        other -> Expect.fail ("Expected Idle 1, got: " ++ Debug.toString other)
            ]
        ]
