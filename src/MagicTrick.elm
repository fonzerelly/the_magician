module MagicTrick exposing (handOut, Game)
import Deck exposing (..)
import Main exposing (Msg(..))
import Deck exposing (ShuffledDeck(..))
import Cards exposing (Card(..))
import List

type alias Game = { left:  ShuffledDeck
                  , center: ShuffledDeck
                  , right: ShuffledDeck
                  }

emptyDeck: ShuffledDeck
emptyDeck = newDeck []
-- implement appendLeft appendCenter and appendRight
-- pass that function to handOutRecursivly
-- 
-- appendLeft: Card -> Game -> Game
-- appendLeft card game = { game | left = appendCard card (.left game)}

-- appendCenter: Card -> Game -> Game
-- appendCenter card game = { game | center = appendCard card (.center game)}

-- appendRight: Card -> Game -> Game
-- appendRight card game = { game | left = appendCard card (.left game)}

-- type GameDeck = Left | Center | Right

-- handOutRecursivly: (Game, ShuffledDeck, GameDeck)-> (Game, ShuffledDeck, GameDeck)
-- handOutRecursivly gameState =
--     let 
--         (game, deck, gamedeck) = gameState
--         (nextCard, restDeck) = draw deck
--     in
--         case nextCard of
--            Back -> (game, restDeck, Left)
--            _ -> 
--                 case gamedeck of
--                     Left -> (appendLeft nextCard game, restDeck, Center)
--                     Center -> (appendCenter nextCard game, restDeck, Right)
--                     Right -> (appendRight nextCard game, restDeck, Left)

-- handOut : ShuffledDeck -> Game
-- handOut deck = 
--     let
--         (game, _, _) = handOutRecursivly 
--             ( { left = emptyDeck
--               , center = emptyDeck
--               , right = emptyDeck 
--               }
--             , deck
--             , Left
--             )
--     in
--         game
cardOfTuple: (Int, Card) -> Card
cardOfTuple (index, card) = card

isNthOf: Int -> (Int, a) -> Bool
isNthOf n (index, _) = n == modBy 3 index

toIndexedCard: Int -> Card -> (Int, Card)
toIndexedCard index card = (index, card)
handOut : ShuffledDeck -> Game
handOut deck =
    let
        indexedCards = List.indexedMap toIndexedCard (getCards deck)
    in
    { left = newDeck (List.map cardOfTuple (List.filter (isNthOf <| 0) indexedCards))
    , center = newDeck (List.map cardOfTuple (List.filter (isNthOf <| 1) indexedCards))
    , right = newDeck (List.map cardOfTuple (List.filter (isNthOf <| 2) indexedCards))
    }