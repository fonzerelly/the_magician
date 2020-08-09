module MagicTrickTests exposing (..)

import Test exposing (..)
import Expect

import Cards exposing (..)
import Deck exposing (..)
import CardRepresentation exposing (cardName)

import MagicTrick exposing (Game, UserSelection(..), ProperSizedDeck, SlicedDeck(..), length, createProperSizedDeck, downSize, handOut, mergeGame, readMind)
import List
import Cards exposing (Face(..))
import Maybe.FlatMap exposing (flatMap)


all : Test
all = 
    describe "MagicTrick"
        [ 
            describe "downSize"
            [ test "should return Nothing for absurd number of cards" <|
                \_ ->
                    downSize [] |> Expect.equal []
            
            , test "should not change the size of a proper sized" <|
                \_ ->
                    let
                        rightSizedDeck = [ Card Hearts Ace
                                         , Card Spades Ace
                                         , Card Clubs Ace
                                         ]
                        properSizedDeck = downSize rightSizedDeck
                    in
                        List.length properSizedDeck |> Expect.equal 3

            , test "should change the size of invalid sized deck" <|
                \_ ->
                    let
                        invalidSizedDeck = [ Card Hearts Ace, Card Spades Ace, Card Clubs Ace
                                           , Card Hearts King, Card Spades King, Card Clubs King
                                           , Card Hearts Queen, Card Spades Queen, Card Clubs Queen
                                           , Card Hearts Jack, Card Spades Jack, Card Clubs Jack
                                           ]
                        properSizedDeck = downSize invalidSizedDeck
                    in
                        List.length properSizedDeck |> Expect.equal 9
                        
            ]
         , 
         describe "createProperSizedDeck"
            [ test "should verify deck of three" <|
                \_-> 
                    let
                        rightSizedDeck = [ Card Hearts Ace
                                         , Card Spades Ace
                                         , Card Clubs Ace
                                         ]
                        properSizedDeck = createProperSizedDeck rightSizedDeck
                    in
                        Result.map MagicTrick.length properSizedDeck |> Expect.equal (Ok 3)
            , test "should error on deck of six" <|
                \_->
                    let
                        invalidSizedDeck = [ Card Hearts Ace, Card Hearts King
                                         , Card Spades Ace, Card Spades King
                                         , Card Clubs Ace, Card Clubs King
                                         ]
                        error = createProperSizedDeck invalidSizedDeck
                    in
                        error |> Expect.equal (Result.Err "A deck needs to be odd!")

            , test "should error on deck of seven" <|
                \_->
                    let
                        invalidSizedDeck = [ Card Hearts Ace, Card Hearts King
                                         , Card Spades Ace, Card Spades King
                                         , Card Clubs Ace, Card Clubs King
                                         , Card Diamonds Ace
                                         ]
                        error = createProperSizedDeck invalidSizedDeck
                    in
                        error |> Expect.equal (Result.Err "A deck needs to be dividable by three!")
            ]
         , describe "handOut"
            [ test "should split shuffledDeck up to three decks" <|
                \_ ->
                    let
                        deckOfThree = 
                            [ Card Hearts Ace
                            , Card Spades Ace
                            , Card Clubs Ace
                            ] |> createProperSizedDeck
                    in
                        Result.map handOut deckOfThree |> Expect.all
                            [ \result -> Result.map .left result |> Expect.equal ([Card Hearts Ace] |> SlicedDeck |> Ok)
                            , \result -> Result.map .center result |> Expect.equal ([Card Spades Ace] |> SlicedDeck |> Ok)
                            , \result -> Result.map .right result |> Expect.equal ([Card Clubs Ace] |> SlicedDeck |> Ok)
                            ]
            , test "should split deck of nine up to three decks with three" <|
                \_ ->
                    let
                        deckOfNine = createProperSizedDeck
                            [ Card Hearts Ace, Card Hearts King, Card Hearts Queen
                            , Card Spades Ace, Card Spades King, Card Spades Queen
                            , Card Clubs Ace, Card Clubs King, Card Clubs Queen
                            ]
                        expectedLeft = [Card Hearts Ace, Card Spades Ace, Card Clubs Ace] |> SlicedDeck |> Ok
                        expectedCenter = [Card Hearts King, Card Spades King, Card Clubs King] |> SlicedDeck |> Ok
                        expectedRight = [Card Hearts Queen, Card Spades Queen, Card Clubs Queen] |> SlicedDeck |> Ok
                    in
                        Result.map handOut deckOfNine |> Expect.all
                            [ \result -> Result.map .left result |> Expect.equal expectedLeft
                            , \result -> Result.map .center result |> Expect.equal expectedCenter
                            , \result -> Result.map .right result |> Expect.equal expectedRight
                            ]
            ]
        , describe "mergeGame"
            [  test "should merge left deck into middle when user selects left" <|
                \_ ->
                    let
                        game = { left = [Card Hearts Ace] |> SlicedDeck
                               , center = [Card Spades Ace] |> SlicedDeck
                               , right = [Card Clubs Ace] |> SlicedDeck
                               }
                        expectedDeck = [ Card Spades Ace
                                       , Card Hearts Ace
                                       , Card Clubs Ace
                                       ] |> createProperSizedDeck
                    in
                        mergeGame UserTookLeft game |> Expect.equal expectedDeck
           
            , test "should merge right deck into middle when user selects r" <|
                \_ ->
                    let
                        game = { left = [Card Hearts Ace] |> SlicedDeck
                               , center = [Card Spades Ace] |> SlicedDeck
                               , right = [Card Clubs Ace] |> SlicedDeck
                               }
                        expectedDeck = [ Card Hearts Ace
                                       , Card Clubs Ace
                                       , Card Spades Ace
                                       ] |> createProperSizedDeck
                    in
                        mergeGame UserTookRight game |> Expect.equal expectedDeck
           
            , test "should merge center deck into middle when user selects center" <|
                \_ ->
                    let
                        game = { left = [Card Hearts Ace] |> SlicedDeck
                               , center = [Card Spades Ace] |> SlicedDeck
                               , right = [Card Clubs Ace] |> SlicedDeck
                               }
                        expectedDeck = [ Card Hearts Ace
                                       , Card Spades Ace
                                       , Card Clubs Ace
                                       ] |> createProperSizedDeck
                    in
                        mergeGame UserTookCenter game |> Expect.equal expectedDeck
                                   
            , test "should merge a deck of nine cards" <|
                \_ ->
                    let
                        game = { left = 
                                    [ Card Hearts Ace
                                    , Card Hearts King
                                    , Card Hearts Queen
                                    ] |> SlicedDeck
                               , center =
                                    [ Card Spades Ace
                                    , Card Spades King
                                    , Card Spades Queen
                                    ] |> SlicedDeck
                               , right =
                                    [ Card Clubs Ace
                                    , Card Clubs King
                                    , Card Clubs Queen
                                    ] |> SlicedDeck
                               }
                        expectedDeck = [ Card Spades Ace
                                       , Card Spades King
                                       , Card Spades Queen
                                       , Card Hearts Ace
                                       , Card Hearts King
                                       , Card Hearts Queen
                                       , Card Clubs Ace
                                       , Card Clubs King
                                       , Card Clubs Queen
                                       ] |> createProperSizedDeck
                    in
                        mergeGame UserTookLeft game |> Expect.equal expectedDeck
            ]
        , describe "readMind" <|
            List.map (\(deck, card) -> test ("should pick " ++ (viewCard >> Tuple.second) card) <|
                \_ -> Maybe.andThen readMind (deck |> createProperSizedDeck |> Result.toMaybe) |> Expect.equal (Just card))
                    [ ( [ Card Hearts Ace
                        , Card Spades Ace
                        , Card Clubs Ace
                        ]
                        , Card Spades Ace
                        )
                    , ( [ Card Spades Ace
                        , Card Spades King
                        , Card Spades Queen
                        , Card Hearts Ace
                        , Card Hearts King
                        , Card Hearts Queen
                        , Card Clubs Ace
                        , Card Clubs King
                        , Card Clubs Queen
                        ]
                      , Card Hearts King
                      )
                    ]
        ]