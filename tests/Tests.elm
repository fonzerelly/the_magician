module Tests exposing (..)

import Test exposing (..)
import Fuzz exposing (..)
import Expect
--import Cards exposing (suitName, faceName, Face (..), Suit(..), Card, cardName, createDeck, toFace,faceToInt)
import Cards exposing (..)
import CardTrick exposing (faceName, suitName, cardName)


-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!


all : Test
all =
    describe "A Test Suite"        
        [ test "faceName should turn Ace to 'A'" <|
            \_ ->
                faceName Ace |> Expect.equal "A" 
        , test "faceName should turn King to 'K'" <|
            \_ ->
                faceName King |> Expect.equal "K"
        , test "faceName should turn Queen to 'Q'" <|
            \_ ->
                faceName Queen |> Expect.equal "Q"
        , test "faceName should turn Jack to 'J'" <|
            \_ ->
                faceName Jack |> Expect.equal "J"
        , test "faceName should turn Ten to '10'" <|
            \_ ->
                faceName Ten |> Expect.equal "10"
        , test "faceName should turn Nine to '9'" <|
            \_ ->
                faceName Nine |> Expect.equal "9"
        , test "faceName should turn Eight to '8'" <|
            \_ ->
                faceName Eight |> Expect.equal "8"
        , test "faceName should turn Seven to '7'" <|
            \_ ->
                faceName Seven |> Expect.equal "7"
        , test "faceName should turn Six to '6'" <|
            \_ ->
                faceName Six |> Expect.equal "6"
        , test "faceName should turn Five to '5'" <|
            \_ ->
                faceName Five |> Expect.equal "5"
        , test "faceName should turn Four to '4'" <|
            \_ ->
                faceName Four |> Expect.equal "4"
        , test "faceName should turn Three to '3'" <|
            \_ ->
                faceName Three |> Expect.equal "3"
        , test "faceName should turn Two to '2'" <|
            \_ ->
                faceName Two |> Expect.equal "2"
        , test "suiteName should turn Spade to 'S'" <|
            \_->
                suitName Spades |> Expect.equal "S"
        , test "suiteName should turn Clubs to 'C'" <|
            \_->
                suitName Clubs |> Expect.equal "C"
        , test "suiteName should turn Heart to 'H'" <|
            \_->
                suitName Hearts |> Expect.equal "H"
        , test "suiteName should turn Diamond to 'D'" <|
            \_->
                suitName Diamonds |> Expect.equal "D"

        , test "cardName should turn Diamond Seven to 'D7'" <|
            \_->
                let
                    card = Card Diamonds Seven
                in
                cardName card |> Expect.equal "D7"
        
        ]

-- isTrue : Expect.Expectation
-- isTrue = Expect.equal 1 1

-- isFalse : Expect.Expectation
-- isFalse = Expect.equal 1 2

-- anotherTestSuite : Test
-- anotherTestSuite =
--     describe "2nd test suite"
--         [
--             describe "Card deck functions" 
--                 [ 
--                     test "createDeck returns a deck with 52 cards" <|
--                         \_ ->
--                             createDeck 
--                             |> List.length 
--                             |> Expect.equal 52
--                     , fuzz (intRange 1 13) "a deck has 4 of each face" <|
--                         \num ->
--                             case toFace num of
--                                 Just face ->
--                                     createDeck 
--                                     |> List.filter (\card -> card.face == face)
--                                     |> List.length
--                                     |> Expect.equal 4
--                                 Nothing -> isFalse
--                 ]
--             , describe "Card helper functions" 
--                 [
--                     fuzz int "toFace converts numbers 1 through 13 to Just Face, otherwise returns Nothing" <|
--                         \number ->
--                             if number >= 1 && number <= 13 then 
--                                 case toFace number of
--                                     Just _ -> isTrue
--                                     Nothing -> isFalse
--                             else 
--                                 case toFace number of
--                                     Just _ -> isFalse
--                                     Nothing -> isTrue
--                 ]                    
--         ] 
