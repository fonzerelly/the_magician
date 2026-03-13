module CardRepresentationTests exposing (..)

import Test exposing (..)
import Fuzz exposing (..)
import Expect

import Cards exposing (..)
import CardRepresentation exposing (..)
import Html exposing (img)
import Html.Attributes exposing (src)
import Cards exposing (Face(..))

all : Test
all =
    describe "CardRepresentation"
        [ describe "faceName"
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
            ]
        , describe "suitName"
            [ test "suiteName should turn Spade to 'S'" <|
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
            ]
        , describe "cardName"
            [ test "cardName should turn Diamond Seven to 'D7'" <|
                \_->
                    let
                        card = Card Diamonds Seven
                    in
                    cardName card |> Expect.equal "D7"
            ]
        , describe "toHtml"
            [ test "should turn Ace of Spades into image tag" <|
                \_->
                    let
                        card = Card Spades Ace
                    in
                    toHtml card |> Expect.equal (img [src "src/card-deck/SA.svg"] [])
            ]
        , describe "toPath"
            [ test "should turn Ace of Spades into elm-ui-image of size 500" <|
                \_->
                    let
                        card = Card Spades Ace
                    in
                    toPath card |> Expect.equal "src/card-deck/SA.svg"
            ]
        , describe "suitLabel"
            [ test "suitLabel should turn Spades to 'Pik'" <|
                \_ -> suitLabel Spades |> Expect.equal "Pik"
            , test "suitLabel should turn Clubs to 'Kreuz'" <|
                \_ -> suitLabel Clubs |> Expect.equal "Kreuz"
            , test "suitLabel should turn Hearts to 'Herz'" <|
                \_ -> suitLabel Hearts |> Expect.equal "Herz"
            , test "suitLabel should turn Diamonds to 'Karo'" <|
                \_ -> suitLabel Diamonds |> Expect.equal "Karo"
            ]
        , describe "faceLabel"
            [ test "faceLabel should turn Ace to 'Ass'" <|
                \_ -> faceLabel Ace |> Expect.equal "Ass"
            , test "faceLabel should turn King to 'König'" <|
                \_ -> faceLabel King |> Expect.equal "König"
            , test "faceLabel should turn Queen to 'Dame'" <|
                \_ -> faceLabel Queen |> Expect.equal "Dame"
            , test "faceLabel should turn Jack to 'Bube'" <|
                \_ -> faceLabel Jack |> Expect.equal "Bube"
            , test "faceLabel should turn Seven to '7'" <|
                \_ -> faceLabel Seven |> Expect.equal "7"
            ]
        , describe "cardLabel"
            [ test "cardLabel should turn Hearts Seven to 'Herz 7'" <|
                \_ -> cardLabel (Card Hearts Seven) |> Expect.equal "Herz 7"
            , test "cardLabel should turn Spades Queen to 'Pik Dame'" <|
                \_ -> cardLabel (Card Spades Queen) |> Expect.equal "Pik Dame"
            ]
        ]
