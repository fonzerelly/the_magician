module MagicTrickIntegrationTests exposing (..)

import Test exposing (..)
import Expect 
import MagicTrick exposing (createProperSizedDeck)
import Cards exposing (Face(..))
import MagicTrick exposing (Game, SlicedDeck(..), UserSelection(..), ProperSizedDeck, mergeGame2)
import Cards exposing (Card (..), Suit(..), Face(..))


all: Test
all =
    describe "MagicTrick Integration"
        [ describe "merge"
            [ test "should return the simple Result a round" <|
                \_ ->
                    let
                        game = Result.Ok { left = SlicedDeck [Card Spades Ace]
                                         , center = SlicedDeck [Card Hearts Ace]
                                         , right = SlicedDeck [Card Clubs Ace]
                                         }
                        selection =  Result.Ok UserTookLeft
                        expectedMergedDeck = createProperSizedDeck [ Card Hearts Ace
                                                                   , Card Spades Ace
                                                                   , Card Clubs Ace
                                                                   ]
                        
                        join : Result x (Result x a) -> Result x a
                        join mx =
                            case mx of
                                Ok x ->
                                    x

                                Err err ->
                                    Err err

                        
                        result1 = Result.map2 mergeGame2 selection game
                        -- result = join result1

                    in
                    Expect.equal expectedMergedDeck result1
            ]
        ]
