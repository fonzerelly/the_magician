module FuzzMagicTrickTests exposing (..)

import Expect
import Fuzz exposing (..)
import Test exposing (..)
import Test exposing (Test)
import MagicTrick exposing (ProperSizedDeck)
import Deck exposing (ShuffledDeck)
import Debug exposing (log)
import Cards exposing (Card(..), Face(..), Suit(..))
import List exposing (..)
import Cards exposing (..)
import Deck exposing (fullDeck, getCards)
import CardRepresentation exposing (cardName)
import Array
import MagicTrick exposing (createProperSizedDeck, handOut, SlicedDeck(..), Game, UserSelection(..), mergeGame2, representProperSizedDeck, representGame, readMind)
import Expect exposing (true)
import Html exposing (a)

mergeGame = mergeGame2

-- test config --
wantOutput = False

createTest: Int -> Test
createTest decksize = 
        describe ("deckSize " ++ (Debug.toString decksize))
            [ fuzz (intRange 0 decksize) "should find card" <|
                \randomCardIndex ->
                    let
                        

                        log : String -> a -> a
                        log msg a = if wantOutput 
                            then Debug.log msg a
                            else a

                        findCard: Card -> SlicedDeck -> Bool
                        findCard cardToFind slicedDeck =  case slicedDeck of
                           SlicedDeck d -> List.member cardToFind d

                        -- Is it valid to support an Else-Branch? There was a bug in findCard that
                        simulateUser: Card -> Game -> UserSelection
                        simulateUser card game =
                            if game |> .left |> findCard card then
                                UserTookLeft
                            else if game |> .center |> findCard card then
                                UserTookCenter
                            else if game |> .right |> findCard card then
                                UserTookRight
                            else
                                log "Did not find card anywhere" UserTookRight

                        simulateRound: Int -> Card -> Result String ProperSizedDeck -> Result String ProperSizedDeck
                        simulateRound roundNr memorizedCard properSizedDeck =
                            let
                                roundLabel = (Debug.toString roundNr)
                                y10 = log ("Deck " ++ roundLabel) (Result.map representProperSizedDeck properSizedDeck)

                                round = Result.map handOut properSizedDeck
                                y20 = log ("Round " ++ roundLabel) (Result.map representGame round)

                                choice = Result.map (simulateUser memorizedCard) round
                                y30 = log ("Choice " ++ roundLabel) choice

                                result = Result.map2 mergeGame choice round
                                y40 = log ("Resulting Deck after Round " ++ roundLabel) (Result.map representProperSizedDeck result)
                            in
                                result


                        x00 = log "***********************************" True
                        deck = fullDeck |> getCards |> List.take decksize

                        memorized = case Array.get randomCardIndex (Array.fromList deck) of
                           Just card -> card
                           Nothing -> Card Spades Ace



                        x03 = log "Initial random number" randomCardIndex
                        x05 = log "Memorized Card " (cardName memorized)

                        checkedDeck = createProperSizedDeck deck
                        
                        secondDeck = simulateRound 1 memorized checkedDeck

                        thirdDeck = simulateRound 2 memorized secondDeck

                        fourthDeck = simulateRound 3 memorized thirdDeck

                        readCard = case Result.map readMind fourthDeck of
                           Ok card -> card
                           Err msg -> log msg (Just Back)
                        x10 = log "Identified Card " (Maybe.map cardName readCard)
                    in
                        readCard |> Expect.equal (Just memorized)
            ]

createList maximum = List.range 1 maximum 
                  |> List.map (\e -> e * 3)
                  |> List.filter (\e -> modBy 2 e == 1)

sizesOfDeck = createList 100

allTests:Test
allTests = describe "doof" 
    (List.map createTest sizesOfDeck)
    -- [createTest 3, createTest 9]
-- decksize3 = createTest 3
-- decksize9 = createTest 9
-- decksize15 = createTest 15
-- decksize21 = createTest 21
-- decksize27 = createTest 27
-- decksize33 = createTest 33
-- decksize39 = createTest 39
-- decksize45 = createTest 45
-- decksize51 = createTest 51
