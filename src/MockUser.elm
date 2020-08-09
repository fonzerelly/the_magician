module MockUser exposing (selectDeck)

import Cards exposing (Card(..))

import MagicTrick exposing (UserSelection(..), Game, SlicedDeck(..))

findCard: Card -> SlicedDeck -> Bool
findCard cardToFind slicedDeck =  case slicedDeck of
    SlicedDeck d -> List.member cardToFind d


selectDeck: Card -> Game -> UserSelection
selectDeck card game =
    if game |> .left |> findCard card then
        UserTookLeft
    else if game |> .center |> findCard card then
        UserTookCenter
    else
        UserTookRight