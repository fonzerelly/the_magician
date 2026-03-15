module FuzzSuitMatchTests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (Fuzzer)
import Cards exposing (Card(..), Suit(..), Face(..))
import MagicTrick exposing (suitMatchRatio)


-- Fuzzer für eine einzelne Farbe
suitFuzzer : Fuzzer Suit
suitFuzzer =
    Fuzz.oneOf
        [ Fuzz.constant Spades
        , Fuzz.constant Hearts
        , Fuzz.constant Diamonds
        , Fuzz.constant Clubs
        ]


-- Fuzzer für einen Kartenwert
faceFuzzer : Fuzzer Face
faceFuzzer =
    Fuzz.oneOf
        [ Fuzz.constant Ace,   Fuzz.constant Two,   Fuzz.constant Three
        , Fuzz.constant Four,  Fuzz.constant Five,  Fuzz.constant Six
        , Fuzz.constant Seven, Fuzz.constant Eight, Fuzz.constant Nine
        , Fuzz.constant Ten,   Fuzz.constant Jack,  Fuzz.constant Queen
        , Fuzz.constant King
        ]


-- Fuzzer für eine Karte (nur normale Karten, kein Back)
cardFuzzer : Fuzzer Card
cardFuzzer =
    Fuzz.map2 Card suitFuzzer faceFuzzer


allSuits : List Suit
allSuits =
    [ Spades, Hearts, Diamonds, Clubs ]


all : Test
all =
    describe "suitMatchRatio (Fuzz)"
        [ fuzz2 suitFuzzer (Fuzz.list cardFuzzer) "Ergebnis liegt immer in [0.0, 1.0]" <|
            \suit candidates ->
                let
                    ratio = suitMatchRatio suit candidates
                in
                Expect.all
                    [ \r -> Expect.atLeast 0.0 r
                    , \r -> Expect.atMost  1.0 r
                    ]
                    ratio

        , fuzz (Fuzz.list cardFuzzer) "Summe aller vier Farb-Ratios ergibt 1.0 fuer nicht-leere Listen" <|
            \candidates ->
                if List.isEmpty candidates then
                    Expect.pass
                else
                    let
                        total = List.sum (List.map (\s -> suitMatchRatio s candidates) allSuits)
                    in
                    Expect.within (Expect.Absolute 0.001) 1.0 total

        , fuzz2 suitFuzzer (Fuzz.listOfLengthBetween 1 10 faceFuzzer) "Liste mit nur einer Farbe: Ratio dieser Farbe = 1.0" <|
            \suit faces ->
                let
                    candidates = List.map (Card suit) faces
                in
                suitMatchRatio suit candidates
                    |> Expect.within (Expect.Absolute 0.001) 1.0

        , fuzz2 suitFuzzer (Fuzz.listOfLengthBetween 1 10 faceFuzzer) "Liste mit nur einer Farbe: alle anderen Farben haben Ratio 0.0" <|
            \suit faces ->
                let
                    candidates = List.map (Card suit) faces
                    otherSuits = List.filter (\s -> s /= suit) allSuits
                in
                otherSuits
                    |> List.map (\s -> suitMatchRatio s candidates)
                    |> List.all (\r -> r == 0.0)
                    |> Expect.equal True

        , fuzz suitFuzzer "Leere Liste ergibt immer 0.0 unabhaengig von der Farbe" <|
            \suit ->
                suitMatchRatio suit []
                    |> Expect.within (Expect.Absolute 0.001) 0.0
        ]
