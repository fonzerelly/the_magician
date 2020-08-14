module MagicTrickIntegrationTests exposing (..)

import Test exposing (..)
import Expect 
import Cards exposing (Face(..))
import MagicTrick exposing (Game, SlicedDeck(..), UserSelection(..), ProperSizedDeck, mergeGame, createProperSizedDeck)
import Cards exposing (Card (..), Suit(..), Face(..))
import MagicTrickIntegrationTests exposing (game)


all: Test
all =
    describe "MagicTrick Integration"
        [ describe "merge"
            [ test "should return the simple Result a round" <|
                \_ ->
                    let
                        gameResult = Result.Ok { left = SlicedDeck [Card Spades Ace]
                                         , center = SlicedDeck [Card Hearts Ace]
                                         , right = SlicedDeck [Card Clubs Ace]
                                         }
                        selection = Result.Ok UserTookLeft
                        expectedMergedDeck = createProperSizedDeck [ Card Hearts Ace
                                                                   , Card Spades Ace
                                                                   , Card Clubs Ace
                                                                   ]
                        -- result1 = gameResult |> Result.andThen (mergeGame selection)

                        map : (a -> value) -> Result x a -> Result x value
                        andThen : (a -> Result x b) -> Result x a -> Result x b
                        mergeGame : UserSelection -> Game -> Result String ProperSizedDeck

                        andThen mergeGame game
                        map 

                    in
                    Expect.equal expectedMergedDeck result1
            ]
        ]
