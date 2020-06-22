module MagicTrickTests exposing (..)

import Test exposing (..)
import Expect

import Cards exposing (..)
import Deck exposing (..)
import CardRepresentation exposing (cardName)

import MagicTrick exposing (Game, UserSelection(..), ProperSizedDeck, SlicedDeck(..), length, downSize, handOut, mergeGame, readMind)
import List
import Cards exposing (Face(..))
import Maybe.FlatMap exposing (flatMap)

-- deckSize: ProperSizedDeck -> Int
-- deckSize = getCards >> List.length

-- leftSize: Game -> Int
-- leftSize = .left >> deckSize

-- centerSize: Game -> Int
-- centerSize = .center >> deckSize

-- rightSize: Game -> Int
-- rightSize = .center >> deckSize

-- emptyDeck: ProperSizedDeck
-- emptyDeck = ProperSizedDeck newDeck []

all : Test
all = 
    describe "MagicTrick"
        [ describe "downSize"
            [ test "should return Nothing for absurd number of cards" <|
                \_ ->
                    let 
                        absurdSizedDeck = []
                    in
                        downSize absurdSizedDeck |> Expect.equal Nothing
            
            , test "should not change the size of a proper sized" <|
                \_ ->
                    let
                        rightSizedDeck = [ Card Hearts Ace
                                         , Card Spades Ace
                                         , Card Clubs Ace
                                         ]
                        properSizedDeck = downSize rightSizedDeck
                    in
                        Maybe.map MagicTrick.length properSizedDeck |> Expect.equal (Just 3)

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
                        Maybe.map MagicTrick.length properSizedDeck |> Expect.equal (Just 9)
                        
            ]
         , describe "handOut"
            [ test "should split shuffledDeck up to three decks" <|
                \_ ->
                    let
                        deckOfThree = 
                            [ Card Hearts Ace
                            , Card Spades Ace
                            , Card Clubs Ace
                            ] |> downSize
                    in
                        Maybe.map handOut deckOfThree |> Expect.all
                            [ \result -> Maybe.map .left result |> Expect.equal ([Card Hearts Ace] |> SlicedDeck |> Just)
                            , \result -> Maybe.map .center result |> Expect.equal ([Card Spades Ace] |> SlicedDeck |> Just)
                            , \result -> Maybe.map .right result |> Expect.equal ([Card Clubs Ace] |> SlicedDeck |> Just)
                            ]
            , test "should split deck of nine up to three decks with three" <|
                \_ ->
                    let
                        deckOfNine = downSize
                            [ Card Hearts Ace, Card Hearts King, Card Hearts Queen
                            , Card Spades Ace, Card Spades King, Card Spades Queen
                            , Card Clubs Ace, Card Clubs King, Card Clubs Queen
                            ]
                        expectedLeft = [Card Hearts Ace, Card Spades Ace, Card Clubs Ace] |> SlicedDeck |> Just
                        expectedCenter = [Card Hearts King, Card Spades King, Card Clubs King] |> SlicedDeck |> Just
                        expectedRight = [Card Hearts Queen, Card Spades Queen, Card Clubs Queen] |> SlicedDeck |> Just
                    in
                        Maybe.map handOut deckOfNine |> Expect.all
                            [ \result -> Maybe.map .left result |> Expect.equal expectedLeft
                            , \result -> Maybe.map .center result |> Expect.equal expectedCenter
                            , \result -> Maybe.map .right result |> Expect.equal expectedRight
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
                                       ] |> downSize
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
                                       ] |> downSize
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
                                       ] |> downSize
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
                                       ] |> downSize
                    in
                        mergeGame UserTookLeft game |> Expect.equal expectedDeck
            ]
        , describe "readMind" <|
            List.map (\(deck, card) -> test ("should pick " ++ (viewCard >> Tuple.second) card) <|
                \_ -> flatMap readMind (downSize deck) |> Expect.equal (Just card))
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
                    -- , ( [ Card Hearts Ace
                    --     , Card Hearts King
                    --     , Card Hearts Queen
                    --     , Card Spades Ace
                    --     , Card Spades King
                    --     , Card Spades Queen
                    --     ]
                    --   , Card Hearts Queen
                    --   )
                    ]
        ]