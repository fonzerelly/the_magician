module ErrorCandidatesTests exposing (..)

import Test exposing (..)
import Expect
import Cards exposing (Card(..), Suit(..), Face(..))
import MagicTrick exposing (UserSelection(..), createProperSizedDeck, errorCandidates)


-- Konkretes Beispiel aus ADR 0002:
-- Initiales Deck: ♥Q ♥K ♠8 ♦A ♣3 ♥7 ♠2 ♦K ♣9
-- Wahlen: Left, Center, Center
-- Tatsächliches Ergebnis: ♦A
-- Erwartete Fehlerkandidaten (unique): ♣3, ♥7, ♥Q, ♠2

adrExampleDeck =
    [ Card Hearts Queen
    , Card Hearts King
    , Card Spades Eight
    , Card Diamonds Ace
    , Card Clubs Three
    , Card Hearts Seven
    , Card Spades Two
    , Card Diamonds King
    , Card Clubs Nine
    ]

adrExampleSelections =
    [ UserTookLeft, UserTookCenter, UserTookCenter ]


all : Test
all =
    describe "errorCandidates"
        [ test "liefert 4 eindeutige Fehlerkandidaten fuer das ADR-Beispiel" <|
            \_ ->
                case createProperSizedDeck adrExampleDeck of
                    Err msg ->
                        Expect.fail ("Ungültiges Deck: " ++ msg)

                    Ok deck ->
                        errorCandidates adrExampleSelections deck
                            |> List.length
                            |> Expect.equal 4

        , test "enthaelt Kreuz-Drei als Fehlerkandidat (V1: R1 -> Center)" <|
            \_ ->
                case createProperSizedDeck adrExampleDeck of
                    Err msg ->
                        Expect.fail ("Ungültiges Deck: " ++ msg)

                    Ok deck ->
                        errorCandidates adrExampleSelections deck
                            |> List.member (Card Clubs Three)
                            |> Expect.equal True

        , test "enthaelt Herz-Sieben als Fehlerkandidat (V2: R1 -> Right)" <|
            \_ ->
                case createProperSizedDeck adrExampleDeck of
                    Err msg ->
                        Expect.fail ("Ungültiges Deck: " ++ msg)

                    Ok deck ->
                        errorCandidates adrExampleSelections deck
                            |> List.member (Card Hearts Seven)
                            |> Expect.equal True

        , test "enthaelt Herz-Dame als Fehlerkandidat (V3: R2 -> Left)" <|
            \_ ->
                case createProperSizedDeck adrExampleDeck of
                    Err msg ->
                        Expect.fail ("Ungültiges Deck: " ++ msg)

                    Ok deck ->
                        errorCandidates adrExampleSelections deck
                            |> List.member (Card Hearts Queen)
                            |> Expect.equal True

        , test "enthaelt Pik-Zwei als Fehlerkandidat (V4: R2 -> Right)" <|
            \_ ->
                case createProperSizedDeck adrExampleDeck of
                    Err msg ->
                        Expect.fail ("Ungültiges Deck: " ++ msg)

                    Ok deck ->
                        errorCandidates adrExampleSelections deck
                            |> List.member (Card Spades Two)
                            |> Expect.equal True

        , test "enthaelt NICHT die tatsaechliche Karte (Karo-Ass) des Magiers" <|
            \_ ->
                case createProperSizedDeck adrExampleDeck of
                    Err msg ->
                        Expect.fail ("Ungültiges Deck: " ++ msg)

                    Ok deck ->
                        errorCandidates adrExampleSelections deck
                            |> List.member (Card Diamonds Ace)
                            |> Expect.equal False
        ]
