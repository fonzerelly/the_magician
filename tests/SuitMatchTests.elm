module SuitMatchTests exposing (..)

import Test exposing (..)
import Expect
import Cards exposing (Card(..), Suit(..), Face(..))
import MagicTrick exposing (suitMatchRatio)


-- Hilfsfunktion für Float-Vergleiche mit Toleranz
expectFloat : Float -> Float -> Expect.Expectation
expectFloat expected actual =
    if abs (actual - expected) < 0.001 then
        Expect.pass
    else
        Expect.fail
            ("Expected " ++ String.fromFloat expected
            ++ " but got " ++ String.fromFloat actual)


all : Test
all =
    describe "suitMatchRatio"
        [ test "gibt 0.0 zurueck fuer leere Kandidatenliste" <|
            \_ ->
                suitMatchRatio Clubs []
                    |> expectFloat 0.0

        , test "gibt 1.0 zurueck wenn alle Kandidaten die genannte Farbe haben" <|
            \_ ->
                let
                    allClubs =
                        [ Card Clubs Ace
                        , Card Clubs Two
                        , Card Clubs Three
                        ]
                in
                suitMatchRatio Clubs allClubs
                    |> expectFloat 1.0

        , test "gibt 0.0 zurueck wenn kein Kandidat die genannte Farbe hat" <|
            \_ ->
                let
                    noClubs =
                        [ Card Spades Ace
                        , Card Hearts Two
                        , Card Diamonds Three
                        ]
                in
                suitMatchRatio Clubs noClubs
                    |> expectFloat 0.0

        , test "gibt korrekten Anteil zurueck bei gemischter Liste" <|
            \_ ->
                -- 2 von 6 Kandidaten sind Kreuz → 2/6 ≈ 0.333
                let
                    candidates =
                        [ Card Clubs Six      -- Kreuz
                        , Card Spades Nine
                        , Card Spades Four
                        , Card Clubs Five     -- Kreuz
                        , Card Diamonds Ten
                        , Card Diamonds Seven
                        ]
                in
                suitMatchRatio Clubs candidates
                    |> expectFloat (2.0 / 6.0)

        , test "gibt 0.5 zurueck wenn genau die Haelfte passt" <|
            \_ ->
                let
                    candidates =
                        [ Card Hearts Ace
                        , Card Hearts King
                        , Card Spades Ace
                        , Card Spades King
                        ]
                in
                suitMatchRatio Hearts candidates
                    |> expectFloat 0.5

        , test "funktioniert auch mit weniger als 6 Kandidaten (Duplikate entfernt)" <|
            \_ ->
                -- 3 von 4 Kandidaten sind Pik → 0.75
                let
                    candidates =
                        [ Card Spades Ace
                        , Card Spades King
                        , Card Spades Queen
                        , Card Hearts Ace
                        ]
                in
                suitMatchRatio Spades candidates
                    |> expectFloat 0.75
        ]
