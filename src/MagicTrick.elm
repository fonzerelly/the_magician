module MagicTrick exposing ( Game, UserSelection(..), ProperSizedDeck, SlicedDeck(..)
                           , length, downSize, handOut, mergeGame, readMind
                           )
import Cards exposing (Card(..), Face(..), Suit(..))
import List exposing (..)
import CardRepresentation exposing (cardName)
import Html.Attributes exposing (multiple)
import Array

type alias Game = { left:  SlicedDeck
                  , center: SlicedDeck
                  , right: SlicedDeck
                  }

type alias Deck = List Card

type ProperSizedDeck = ProperSizedDeck Deck
type SlicedDeck = SlicedDeck Deck

type UserSelection = UserTookLeft | UserTookCenter | UserTookRight


downSize: Deck -> Maybe ProperSizedDeck
downSize shuffledDeck =
    let
        decksize = List.length shuffledDeck
        multipleOfThree = div decksize 3

        amount = case modBy 2 multipleOfThree of
            0 -> (multipleOfThree - 1) * 3
            _ -> decksize

        shrinkedDeck = case decksize of 
            0 -> Nothing
            1 -> Nothing
            2 -> Nothing
            _ -> shuffledDeck |> take amount |> ProperSizedDeck |> Just
    in
        shrinkedDeck

length: ProperSizedDeck -> Int
length properSizedDeck = case properSizedDeck of
   ProperSizedDeck deck -> List.length deck

cardOfTuple: (Int, Card) -> Card
cardOfTuple (_, card) = card

isNthOf: Int -> (Int, a) -> Bool
isNthOf n (index, _) = n == modBy 3 index

toIndexedCard: Int -> Card -> (Int, Card)
toIndexedCard index card = (index, card)

div : Int -> Int -> Int
div a b = floor (toFloat a / toFloat b)

unwrapProperSizedDeck : ProperSizedDeck -> List Card
unwrapProperSizedDeck deck = case deck of
   ProperSizedDeck d -> d

unwrapSlicedDeck : SlicedDeck -> List Card
unwrapSlicedDeck deck = case deck of
   SlicedDeck d -> d

handOut : ProperSizedDeck -> Game
handOut deck =
    let
        indexedCards = deck |> unwrapProperSizedDeck |> List.indexedMap toIndexedCard
        everyFirst = 0 |> isNthOf
        everySecond = 1 |> isNthOf
        everyThird = 2 |> isNthOf

    in
    { left = indexedCards |> List.filter everyFirst |> List.map cardOfTuple  |> SlicedDeck
    , center = indexedCards |> List.filter everySecond |> List.map cardOfTuple |> SlicedDeck
    , right = indexedCards |> List.filter everyThird |> List.map cardOfTuple |> SlicedDeck
    }

mergeGame : UserSelection -> Game -> Maybe ProperSizedDeck
mergeGame selection game =
    let
        listOfLeft = .left >> unwrapSlicedDeck
        listOfCenter = .center >> unwrapSlicedDeck
        listOfRight = .right >> unwrapSlicedDeck
    in
        case selection of
            UserTookLeft -> (listOfCenter game ++ listOfLeft game ++ listOfRight game) |> downSize
            UserTookRight -> (listOfLeft game ++ listOfRight game ++ listOfCenter game) |> downSize
            UserTookCenter -> (listOfLeft game ++ listOfCenter game ++ listOfRight game) |> downSize

readMind : ProperSizedDeck -> Maybe Card
readMind deck =
    let
       arrayOfCards = deck |> unwrapProperSizedDeck |> Array.fromList
       indexToPick = div (Array.length arrayOfCards) 2
    in
    arrayOfCards |> Array.get indexToPick