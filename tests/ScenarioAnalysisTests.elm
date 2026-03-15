module ScenarioAnalysisTests exposing (..)

{-
Testet drei Szenarien über alle 21 Karten des Decks:

  1. Troll:               User spielt korrekt, sagt aber "Nein".
                          Loggt suitMatchRatio für die echte Karte.

  2. Nicht-adaptiver      User macht in genau einer Runde eine falsche Wahl,
     Fehler:              wählt danach weiter nach dem *idealen* Pfad.
                          Invariante: echte Karte IMMER in errorCandidates.

  3. Adaptiver Fehler:    User macht in einer Runde einen Fehler und verfolgt
                          die Karte dann im *tatsächlichen* (falsch gemergten) Deck.
                          Kein sauberes Invariant — loggt nur den suitMatchRatio.

Ergebnis: Vergleich der suitMatchRatio-Werte zeigt wie gut das Signal
          im jeweiligen Szenario ist.

Logging aktivieren: wantOutput = True setzen.
-}

import Test exposing (..)
import Expect
import Cards exposing (Card(..), Suit(..), Face(..))
import Deck exposing (fullDeck, getCards)
import Array
import MagicTrick exposing
    ( Game, UserSelection(..), ProperSizedDeck
    , createProperSizedDeck, handOut, mergeGame
    , unwrapSlicedDeck, errorCandidates, suitMatchRatio
    )
import CardRepresentation exposing (cardName)


wantOutput : Bool
wantOutput = False


log : String -> a -> a
log msg a =
    if wantOutput then Debug.log msg a else a


-- ---- Hilfsfunktionen ----

suitOf : Card -> Maybe Suit
suitOf card =
    case card of
        Card s _ -> Just s
        Back     -> Nothing


-- Welchen Stapel enthält die gesuchte Karte im aktuellen Spiel?
findSelection : Card -> Game -> UserSelection
findSelection card game =
    if List.member card (unwrapSlicedDeck game.left) then
        UserTookLeft
    else if List.member card (unwrapSlicedDeck game.center) then
        UserTookCenter
    else
        UserTookRight


-- Simuliert eine Runde mit korrekter Wahl
simulateRound : Card -> ProperSizedDeck -> Maybe ( UserSelection, ProperSizedDeck )
simulateRound card deck =
    let
        game = handOut deck
        sel  = findSelection card game
    in
    mergeGame sel game
        |> Result.toMaybe
        |> Maybe.map (\nextDeck -> ( sel, nextDeck ))


-- Berechnet alle drei korrekten Wahlen für eine gemerkte Karte
idealSelectionsFor : Card -> ProperSizedDeck -> Maybe (List UserSelection)
idealSelectionsFor card initialDeck =
    simulateRound card initialDeck
        |> Maybe.andThen (\( s1, d2 ) ->
            simulateRound card d2
                |> Maybe.andThen (\( s2, d3 ) ->
                    simulateRound card d3
                        |> Maybe.map (\( s3, _ ) -> [ s1, s2, s3 ])
                )
        )


-- Gibt eine garantiert andere (falsche) Wahl zurück
wrong : UserSelection -> UserSelection
wrong sel =
    case sel of
        UserTookLeft   -> UserTookCenter
        UserTookCenter -> UserTookLeft
        UserTookRight  -> UserTookLeft


replaceAt : Int -> a -> List a -> List a
replaceAt idx new =
    List.indexedMap (\i v -> if i == idx then new else v)


ratioForCard : Card -> List Card -> Float
ratioForCard card candidates =
    suitOf card
        |> Maybe.map (\s -> suitMatchRatio s candidates)
        |> Maybe.withDefault 0.0


-- ---- Szenario 1: Troll ----
-- Behauptung: suitMatchRatio variiert je nach Deck-Verteilung (kein festes Signal)

trollTest : Card -> List UserSelection -> ProperSizedDeck -> Test
trollTest card idealSels deck =
    test ("Troll: " ++ cardName card) <|
        \_ ->
            let
                candidates = errorCandidates idealSels deck
                ratio      = ratioForCard card candidates
                _          = log ("Troll " ++ cardName card ++ " ratio") ratio
            in
            -- Kein hartes Invariant für den Troll — wir prüfen nur den Wertebereich
            Expect.all
                [ \r -> Expect.atLeast 0.0 r
                , \r -> Expect.atMost  1.0 r
                ]
                ratio


-- ---- Szenario 2: Nicht-adaptiver Fehler ----
-- Invariante: echte Karte IMMER in errorCandidates
-- Begründung: Korrigieren der Falsch-Wahl ergibt exakt den idealen Pfad → readMind = echte Karte

nonAdaptiveMistakeTest : Card -> List UserSelection -> ProperSizedDeck -> Int -> Test
nonAdaptiveMistakeTest card idealSels deck roundIdx =
    test ("Nicht-adaptiver Fehler R" ++ String.fromInt (roundIdx + 1) ++ ": " ++ cardName card) <|
        \_ ->
            let
                correctSel =
                    Array.fromList idealSels
                        |> Array.get roundIdx
                        |> Maybe.withDefault UserTookLeft

                actualSels = replaceAt roundIdx (wrong correctSel) idealSels
                candidates = errorCandidates actualSels deck
                ratio      = ratioForCard card candidates

                _ = log ("Nicht-adaptiv R" ++ String.fromInt (roundIdx + 1)
                        ++ " " ++ cardName card ++ " ratio") ratio
            in
            candidates
                |> List.member card
                |> Expect.equal True


-- ---- Szenario 3: Adaptiver Fehler ----
-- User macht Fehler in roundIdx, verfolgt Karte danach im *tatsächlichen* Deck weiter
-- Kein hartes Invariant — suitMatchRatio-Wert wird geloggt

adaptiveMistakeTest : Card -> List UserSelection -> ProperSizedDeck -> Int -> Test
adaptiveMistakeTest card idealSels deck roundIdx =
    test ("Adaptiver Fehler R" ++ String.fromInt (roundIdx + 1) ++ ": " ++ cardName card) <|
        \_ ->
            let
                correctSel =
                    Array.fromList idealSels
                        |> Array.get roundIdx
                        |> Maybe.withDefault UserTookLeft

                -- Runden vor dem Fehler: ideal; Fehler-Runde: wrong; danach: Karte im tatsächlichen Deck verfolgen
                adaptiveSels =
                    idealSels
                        |> List.indexedMap (\i sel ->
                            if i == roundIdx then wrong correctSel else sel
                        )
                        |> recomputeAfter roundIdx card deck

                candidates = errorCandidates adaptiveSels deck
                ratio      = ratioForCard card candidates

                _ = log ("Adaptiv R" ++ String.fromInt (roundIdx + 1)
                        ++ " " ++ cardName card ++ " ratio") ratio
            in
            Expect.all
                [ \r -> Expect.atLeast 0.0 r
                , \r -> Expect.atMost  1.0 r
                ]
                ratio


-- Berechnet die Wahlen nach dem Fehler neu: ab Runde roundIdx+1 Karte im tatsächlichen Deck verfolgen
recomputeAfter : Int -> Card -> ProperSizedDeck -> List UserSelection -> List UserSelection
recomputeAfter mistakeRound card initialDeck sels =
    let
        -- Simuliert das Deck bis einschließlich Runde mistakeRound
        deckAfterMistake =
            sels
                |> List.take (mistakeRound + 1)
                |> List.foldl
                    (\sel maybeDeck ->
                        maybeDeck
                            |> Maybe.map handOut
                            |> Maybe.andThen (\game -> mergeGame sel game |> Result.toMaybe)
                    )
                    (Just initialDeck)

        -- Berechnet die adaptiven Wahlen für die verbleibenden Runden
        adaptiveRemainder =
            deckAfterMistake
                |> Maybe.andThen
                    (\d ->
                        let
                            remaining = 3 - mistakeRound - 1
                        in
                        if remaining <= 0 then
                            Just []
                        else
                            List.range 0 (remaining - 1)
                                |> List.foldl
                                    (\_ acc ->
                                        acc
                                            |> Maybe.andThen
                                                (\( selsSoFar, currentDeck ) ->
                                                    let
                                                        game = handOut currentDeck
                                                        sel  = findSelection card game
                                                    in
                                                    mergeGame sel game
                                                        |> Result.toMaybe
                                                        |> Maybe.map (\nextDeck -> ( selsSoFar ++ [ sel ], nextDeck ))
                                                )
                                    )
                                    (Just ( [], d ))
                                |> Maybe.map Tuple.first
                    )
    in
    List.take (mistakeRound + 1) sels
        ++ Maybe.withDefault [] adaptiveRemainder


-- ---- Alle Tests für eine Karte ----

testsForCard : ProperSizedDeck -> Card -> List Test
testsForCard deck card =
    case idealSelectionsFor card deck of
        Nothing ->
            [ test ("Konnte ideale Wahlen nicht berechnen fuer " ++ cardName card) <|
                \_ -> Expect.fail "idealSelectionsFor schlug fehl"
            ]

        Just idealSels ->
            [ trollTest card idealSels deck ]
                ++ List.map (nonAdaptiveMistakeTest card idealSels deck) [ 0, 1, 2 ]
                ++ List.map (adaptiveMistakeTest card idealSels deck) [ 0, 1, 2 ]


-- ---- Haupttest ----

all : Test
all =
    let
        allCards = fullDeck |> getCards |> List.take 21
    in
    case allCards |> createProperSizedDeck |> Result.toMaybe of
        Nothing ->
            test "Konnte 21-Karten-Deck nicht erstellen" <|
                \_ -> Expect.fail "createProperSizedDeck schlug fehl"

        Just deck ->
            describe "Szenario-Analyse über alle 21 Karten"
                (List.concatMap (testsForCard deck) allCards)
