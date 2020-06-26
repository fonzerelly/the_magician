module MagicTrick exposing ( Game, UserSelection(..), ProperSizedDeck, SlicedDeck(..)
                           , length, downSize, handOut, mergeGame, readMind, createProperSizedDeck
                           )
import Cards exposing (Card(..), Face(..), Suit(..))
import List exposing (..)
import CardRepresentation exposing (cardName)
import Html.Attributes exposing (multiple)
import Array
import Result

type alias Game = { left:  SlicedDeck
                  , center: SlicedDeck
                  , right: SlicedDeck
                  }

type alias Deck = List Card

type ProperSizedDeck = ProperSizedDeck Deck
type SlicedDeck = SlicedDeck Deck

type UserSelection = UserTookLeft | UserTookCenter | UserTookRight

createProperSizedDeck: Deck -> Result String ProperSizedDeck 
createProperSizedDeck deck =
    let
        deckSize = List.length deck

        isMultipleOfThree: Int -> Bool
        isMultipleOfThree size = modBy 3 size |> (==) 0
        
        isOdd: Int -> Bool
        isOdd size = modBy 2 size |> (==) 1

        isValid: Int -> Bool
        isValid size = isOdd size && isMultipleOfThree size
    in
        if isValid deckSize then
            deck |> ProperSizedDeck |> Result.Ok
        else 
            if isOdd deckSize then
                Result.Err "A deck needs to be dividable by three!"
            else
                Result.Err "A deck needs to be odd!"

downSize: Deck -> Deck
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
        shuffledDeck |> List.take amount

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

mergeGame : UserSelection -> Game -> Result String ProperSizedDeck
mergeGame selection game =
    let
        listOfLeft = .left >> unwrapSlicedDeck
        listOfCenter = .center >> unwrapSlicedDeck
        listOfRight = .right >> unwrapSlicedDeck
    in
        case selection of
            UserTookLeft -> (listOfCenter game ++ listOfLeft game ++ listOfRight game) |> createProperSizedDeck
            UserTookRight -> (listOfLeft game ++ listOfRight game ++ listOfCenter game) |> createProperSizedDeck
            UserTookCenter -> (listOfLeft game ++ listOfCenter game ++ listOfRight game) |> createProperSizedDeck

readMind : ProperSizedDeck -> Maybe Card
readMind deck =
    let
       arrayOfCards = deck |> unwrapProperSizedDeck |> Array.fromList
       indexToPick = div (Array.length arrayOfCards) 2
    in
    arrayOfCards |> Array.get indexToPick