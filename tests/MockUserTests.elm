module MockUserTests exposing (..)

import Test exposing (..)
import Expect 
import MagicTrick exposing (Game, SlicedDeck(..), UserSelection(..))
import Cards exposing (Card (..), Suit(..), Face(..))

import MockUser exposing (..)

all: Test
all =
    describe "MockUser"
        [ describe "selectDeck"
            [ test "should return UserTookLeft when card is in left deck" <|
                \_ ->
                    let
                        card = Card Spades Ace
                        game = { left = SlicedDeck [Card Spades Ace]
                               , center = SlicedDeck [Card Hearts Ace]
                               , right = SlicedDeck [Card Clubs Ace]
                               }
                    in
                    selectDeck card game |> Expect.equal UserTookLeft
            , test "should return UserTookRight when card is in right deck" <|
                \_ ->
                    let
                        card = Card Clubs Ace
                        game = { left = SlicedDeck [Card Spades Ace]
                               , center = SlicedDeck [Card Hearts Ace]
                               , right = SlicedDeck [Card Clubs Ace]
                               }
                    in
                    selectDeck card game |> Expect.equal UserTookRight

            , test "should return UserTookCenter when card is in center deck" <|
                \_ ->
                    let
                        card = Card Hearts Ace
                        game = { left = SlicedDeck [Card Spades Ace]
                               , center = SlicedDeck [Card Hearts Ace]
                               , right = SlicedDeck [Card Clubs Ace]
                               }
                    in
                    selectDeck card game |> Expect.equal UserTookCenter
            ]
        ]