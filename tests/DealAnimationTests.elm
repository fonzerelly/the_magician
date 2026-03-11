module DealAnimationTests exposing (..)

import Test exposing (..)
import Expect
import DealAnimation exposing (Pile(..), dealDestination, AnimPhase(..), tick, flipScale, slideOffset, pileId, drawPileId, PilePositions)
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

        , describe "flipScale"
            [ test "Idle gibt 1.0 zurück" <|
                \_ -> flipScale (Idle 0) |> Expect.within (Expect.Absolute 0.001) 1.0

            , test "Shrinking bei progress 0.0 gibt 1.0 zurück" <|
                \_ ->
                    let anim = { index = 0, card = Back, dest = PileCenter, progress = 0.0 }
                    in flipScale (Shrinking anim) |> Expect.within (Expect.Absolute 0.001) 1.0

            , test "Shrinking bei progress 0.5 gibt 0.5 zurück" <|
                \_ ->
                    let anim = { index = 0, card = Back, dest = PileCenter, progress = 0.5 }
                    in flipScale (Shrinking anim) |> Expect.within (Expect.Absolute 0.001) 0.5

            , test "Shrinking bei progress 1.0 gibt 0.0 zurück" <|
                \_ ->
                    let anim = { index = 0, card = Back, dest = PileCenter, progress = 1.0 }
                    in flipScale (Shrinking anim) |> Expect.within (Expect.Absolute 0.001) 0.0

            , test "Expanding bei progress 0.0 gibt 0.0 zurück" <|
                \_ ->
                    let anim = { index = 0, card = Back, dest = PileCenter, progress = 0.0 }
                    in flipScale (Expanding anim) |> Expect.within (Expect.Absolute 0.001) 0.0

            , test "Expanding bei progress 0.3 gibt 0.3 zurück" <|
                \_ ->
                    let anim = { index = 0, card = Back, dest = PileCenter, progress = 0.3 }
                    in flipScale (Expanding anim) |> Expect.within (Expect.Absolute 0.001) 0.3

            , test "Expanding bei progress 1.0 gibt 1.0 zurück" <|
                \_ ->
                    let anim = { index = 0, card = Back, dest = PileCenter, progress = 1.0 }
                    in flipScale (Expanding anim) |> Expect.within (Expect.Absolute 0.001) 1.0

            , test "Sliding gibt 1.0 zurück" <|
                \_ ->
                    let anim = { index = 0, card = Back, dest = PileCenter, progress = 0.5 }
                    in flipScale (Sliding anim) |> Expect.within (Expect.Absolute 0.001) 1.0
            ]

        , describe "pileId und drawPileId"
            [ test "drawPileId ist 'draw-pile'" <|
                \_ -> drawPileId |> Expect.equal "draw-pile"

            , test "pileId PileLeft ist 'pile-left'" <|
                \_ -> pileId PileLeft |> Expect.equal "pile-left"

            , test "pileId PileCenter ist 'pile-center'" <|
                \_ -> pileId PileCenter |> Expect.equal "pile-center"

            , test "pileId PileRight ist 'pile-right'" <|
                \_ -> pileId PileRight |> Expect.equal "pile-right"
            ]

        , describe "slideOffset"
            [ let
                positions : PilePositions
                positions =
                    { drawPile = { x = 200, y = 100 }
                    , left     = { x = 50,  y = 300 }
                    , center   = { x = 200, y = 300 }
                    , right    = { x = 350, y = 300 }
                    }
              in
              describe "mit Beispiel-Positionen"
                [ test "bei progress 0.0 ist der Offset immer (0, 0)" <|
                    \_ ->
                        slideOffset PileRight positions 0.0
                            |> Expect.equal { dx = 0, dy = 0 }

                , test "PileRight bei progress 1.0 gibt vollen Offset nach rechts und unten" <|
                    \_ ->
                        slideOffset PileRight positions 1.0
                            |> Expect.equal { dx = 150, dy = 200 }

                , test "PileLeft bei progress 1.0 gibt vollen Offset nach links und unten" <|
                    \_ ->
                        slideOffset PileLeft positions 1.0
                            |> Expect.equal { dx = -150, dy = 200 }

                , test "PileCenter bei progress 1.0 gibt nur vertikalen Offset" <|
                    \_ ->
                        slideOffset PileCenter positions 1.0
                            |> Expect.equal { dx = 0, dy = 200 }

                , test "PileRight bei progress 0.5 gibt halben Offset" <|
                    \_ ->
                        slideOffset PileRight positions 0.5
                            |> Expect.equal { dx = 75, dy = 100 }
                ]
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
