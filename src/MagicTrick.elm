module MagicTrick exposing (handOut, Game, mergeGame, UserSelection(..), readMind)
import Deck exposing (..)
import Cards exposing (Card(..))
import List
import Cards exposing (Card)
import CardRepresentation exposing (cardName)

type alias Game = { left:  ShuffledDeck
                  , center: ShuffledDeck
                  , right: ShuffledDeck
                  }

emptyDeck: ShuffledDeck
emptyDeck = newDeck []

cardOfTuple: (Int, Card) -> Card
cardOfTuple (_, card) = card

isNthOf: Int -> (Int, a) -> Bool
isNthOf n (index, _) = n == modBy 3 index

toIndexedCard: Int -> Card -> (Int, Card)
toIndexedCard index card = (index, card)
handOut : ShuffledDeck -> Game
handOut deck =
    let
        indexedCards = List.indexedMap toIndexedCard (getCards deck)
        everyFirst = 0 |> isNthOf
        everySecond = 1 |> isNthOf
        everyThird = 2 |> isNthOf

    in
    { left = indexedCards |> List.filter everyFirst |> List.map cardOfTuple |> newDeck
    , center = indexedCards |> List.filter everySecond |> List.map cardOfTuple |> newDeck
    , right = indexedCards |> List.filter everyThird |> List.map cardOfTuple |> newDeck
    }

type UserSelection = UserTookLeft | UserTookCenter | UserTookRight
mergeGame : UserSelection -> Game -> ShuffledDeck
mergeGame selection game = 
    let
        listOfLeft = .left >> getCards
        listOfCenter = .center >> getCards
        listOfRight = .right >> getCards
    in
        case selection of
            UserTookLeft -> newDeck (listOfCenter game ++ listOfLeft game ++ listOfRight game)
            UserTookRight -> newDeck (listOfLeft game ++ listOfRight game ++ listOfCenter game)
            UserTookCenter -> newDeck (listOfLeft game ++ listOfCenter game ++ listOfRight game)

readMind : ShuffledDeck -> Card
readMind deck =
    let
       div : Int -> Int -> Int
       div a b = floor (toFloat a / toFloat b)

       listOfCards = getCards deck

       indexToPick = div (List.length listOfCards) 2
    in
       case List.drop indexToPick (List.take (indexToPick+1) listOfCards) of
            [] -> Back
            pick :: _ -> pick