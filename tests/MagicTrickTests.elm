module MagicTrickTests exposing (..)

import Test exposing (..)
import Expect

import Cards exposing (..)
import Deck exposing (..)

import MagicTrick exposing (handOut, Game)
import List
import Deck exposing (ShuffledDeck(..))
import Cards exposing (Face(..))
import Cards exposing (Suit(..))

deckSize: ShuffledDeck -> Int
deckSize = getCards >> List.length

leftSize: Game -> Int
leftSize = .left >> deckSize

centerSize: Game -> Int
centerSize = .center >> deckSize

rightSize: Game -> Int
rightSize = .center >> deckSize

all : Test
all = 
    describe "MagicTrick"
        [ describe "handOut"
            [ test "should return a list of three decks" <|
                \_ -> 
                    let
                        emptyDeck = Deck.take 0 Deck.fullDeck
                    in
                        handOut emptyDeck |> Expect.all 
                            [ \result -> leftSize result |> Expect.equal 0
                            , \result -> centerSize result |> Expect.equal 0
                            , \result -> rightSize result |> Expect.equal 0
                            ]
            , test "should split shuffledDeck up to three decks" <|
                \_ ->
                    let
                        deckOfThree = newDeck 
                            [ Card Hearts Ace
                            , Card Spades Ace
                            , Card Clubs Ace
                            ]
                    in
                        handOut deckOfThree |> Expect.all
                            [ \result -> .left result |> Expect.equal ([Card Hearts Ace] |> newDeck)
                            , \result -> .center result |> Expect.equal ([Card Spades Ace] |> newDeck)
                            , \result -> .right result |> Expect.equal ([Card Clubs Ace] |> newDeck)
                            ]               
            , test "should split deck of nine up to three decks with three" <|
                \_ ->
                    let
                        deckOfThree = newDeck 
                            [ Card Hearts Ace, Card Hearts King, Card Hearts Queen
                            , Card Spades Ace, Card Spades King, Card Spades Queen
                            , Card Clubs Ace, Card Clubs King, Card Clubs Queen
                            ]
                        expectedLeft = [Card Hearts Ace, Card Spades Ace, Card Clubs Ace] |> newDeck
                        expectedCenter = [Card Hearts King, Card Spades King, Card Clubs King] |> newDeck
                        expectedRight = [Card Hearts Queen, Card Spades Queen, Card Clubs Queen] |> newDeck
                    in
                        handOut deckOfThree |> Expect.all
                            [ \result -> .left result |> Expect.equal (expectedLeft)
                            , \result -> .center result |> Expect.equal (expectedCenter)
                            , \result -> .right result |> Expect.equal (expectedRight)
                            ]
            ]
        ]