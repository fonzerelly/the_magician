module MagicTrickIntegrationTests exposing (..)

import Test exposing (..)
import Expect 
import Cards exposing (Face(..))
import MagicTrick exposing (Game, SlicedDeck(..), UserSelection(..), ProperSizedDeck, mergeGame, createProperSizedDeck)
import Cards exposing (Card (..), Suit(..), Face(..))


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
                        result = Result.map2 mergeGame selection gameResult |> Result.andThen identity
                    in
                    Expect.equal expectedMergedDeck result
            ]
        ]
