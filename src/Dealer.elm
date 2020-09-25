module Dealer exposing (DrawState(..), dealNextCard, iterateDrawState)

import MagicTrick exposing (Game, SlicedDeck(..))


type DrawState
    = Left
    | Center
    | Right


selectStackByDrawState : DrawState -> Game -> SlicedDeck
selectStackByDrawState drawState game =
    case drawState of
        Left ->
            .left game

        Center ->
            .center game

        Right ->
            .right game


tailOfDeck : SlicedDeck -> SlicedDeck
tailOfDeck (SlicedDeck deck) =
    List.tail deck |> Maybe.withDefault [] |> SlicedDeck


newGame : DrawState -> Game -> SlicedDeck -> Game
newGame drawState game deck =
    case drawState of
        Left ->
            { game | left = deck }

        Center ->
            { game | center = deck }

        Right ->
            { game | right = deck }


dealNextCard : Result err Game -> DrawState -> Result err Game
dealNextCard currentGame currentDrawState =
    Result.map
        (\currentGame_ ->
            currentGame_
                |> selectStackByDrawState currentDrawState
                >> tailOfDeck
                >> newGame currentDrawState currentGame_
        )
        currentGame


iterateDrawState : DrawState -> DrawState
iterateDrawState currentDrawState =
    case currentDrawState of
        Left ->
            Center

        Center ->
            Right

        Right ->
            Left
