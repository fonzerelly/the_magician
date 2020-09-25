module DealerTests exposing (all)

import Cards exposing (Card(..), Face(..), Suit(..))
import Dealer exposing (..)
import Expect
import MagicTrick exposing (Game, SlicedDeck(..))
import Test exposing (..)


all : Test
all =
    describe "Dealer"
        [ describe "iterateDrawState"
            [ test "should return Center on Left" <|
                \_ ->
                    iterateDrawState Left |> Expect.equal Center
            , test "should return Right on Center" <|
                \_ ->
                    iterateDrawState Center |> Expect.equal Right
            , test "should return Left on Right" <|
                \_ ->
                    iterateDrawState Right |> Expect.equal Left
            ]
        , describe "dealNextCard"
            [ test "should return Error on Error" <|
                \_ ->
                    dealNextCard (Result.Err "kaputt") Left |> Expect.equal (Result.Err "kaputt")
            , test "should return emptied left stack after dealing card from left stack" <|
                \_ ->
                    let
                        slicedDeck =
                            SlicedDeck [ Card Spades Ace ]

                        game =
                            Game slicedDeck slicedDeck slicedDeck

                        expectedGame =
                            Game (SlicedDeck []) slicedDeck slicedDeck
                    in
                    dealNextCard (Ok game) Left |> Expect.equal (Ok expectedGame)
            ]
        ]
