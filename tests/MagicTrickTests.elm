module MagicTrickTests exposing (..)

import Test exposing (..)
import Expect

import Cards exposing (..)
import Deck exposing (..)

import MagicTrick exposing (handOut, Game, mergeGame, UserSelection(..))
import List
import Cards exposing (Face(..), Suit(..))
import Deck exposing (ShuffledDeck(..))

deckSize: ShuffledDeck -> Int
deckSize = getCards >> List.length

leftSize: Game -> Int
leftSize = .left >> deckSize

centerSize: Game -> Int
centerSize = .center >> deckSize

rightSize: Game -> Int
rightSize = .center >> deckSize

emptyDeck: ShuffledDeck
emptyDeck = newDeck []

all : Test
all = 
    describe "MagicTrick"
        [ describe "handOut"
            [ test "should return a list of three decks" <|
                \_ -> 
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
        , describe "mergeGame"
            [ test "should merge an empty game to a empty deck" <|
                \_ ->
                    let 
                        emptyGame = 
                            { left = emptyDeck
                            , center = emptyDeck
                            , right = emptyDeck
                            }
                    in
                        mergeGame UserTookLeft emptyGame |> Expect.equal (newDeck [])

            , test "should merge left deck into middle when user selects left" <|
                \_ ->
                    let
                        game = { left = newDeck [Card Hearts Ace]
                               , center = newDeck [Card Spades Ace]
                               , right = newDeck [Card Clubs Ace]
                               }
                        expectedDeck = newDeck [ Card Spades Ace
                                               , Card Hearts Ace
                                               , Card Clubs Ace
                                               ]
                    in
                        mergeGame UserTookLeft game |> Expect.equal expectedDeck
           
            , test "should merge right deck into middle when user selects r" <|
                \_ ->
                    let
                        game = { left = newDeck [Card Hearts Ace]
                               , center = newDeck [Card Spades Ace]
                               , right = newDeck [Card Clubs Ace]
                               }
                        expectedDeck = newDeck [ Card Hearts Ace
                                               , Card Clubs Ace
                                               , Card Spades Ace
                                               ]
                    in
                        mergeGame UserTookRight game |> Expect.equal expectedDeck
           
            , test "should merge center deck into middle when user selects center" <|
                \_ ->
                    let
                        game = { left = newDeck [Card Hearts Ace]
                               , center = newDeck [Card Spades Ace]
                               , right = newDeck [Card Clubs Ace]
                               }
                        expectedDeck = newDeck [ Card Hearts Ace
                                               , Card Spades Ace
                                               , Card Clubs Ace
                                               ]
                    in
                        mergeGame UserTookCenter game |> Expect.equal expectedDeck
                                   
            , test "should merge a deck of nine cards" <|
                \_ ->
                    let
                        game = { left = newDeck 
                                    [ Card Hearts Ace
                                    , Card Hearts King
                                    , Card Hearts Queen
                                    ]
                               , center = newDeck 
                                    [ Card Spades Ace
                                    , Card Spades King
                                    , Card Spades Queen
                                    ]
                               , right = newDeck 
                                    [ Card Clubs Ace
                                    , Card Clubs King
                                    , Card Clubs Queen
                                    ]
                               }
                        expectedDeck = newDeck [ Card Spades Ace
                                               , Card Spades King
                                               , Card Spades Queen
                                               , Card Hearts Ace
                                               , Card Hearts King
                                               , Card Hearts Queen
                                               , Card Clubs Ace
                                               , Card Clubs King
                                               , Card Clubs Queen
                                               ]
                    in
                        mergeGame UserTookLeft game |> Expect.equal expectedDeck
            ]
        ]