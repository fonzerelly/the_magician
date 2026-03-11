module DealAnimation exposing (Pile(..), dealDestination, AnimPhase(..), AnimData, tick, flipScale, slideOffset, pileId, drawPileId, PilePositions, isDealingDone)

import Cards exposing (Card(..))


type Pile
    = PileLeft
    | PileCenter
    | PileRight


type alias AnimData =
    { index : Int
    , card : Card
    , dest : Pile
    , progress : Float
    }


type AnimPhase
    = Idle Int
    | Shrinking AnimData
    | Expanding AnimData
    | Sliding AnimData


type alias Position =
    { x : Float, y : Float }


type alias PilePositions =
    { drawPile : Position
    , left     : Position
    , center   : Position
    , right    : Position
    }


{-| HTML-ID des Ziehstapel-Elements. -}
drawPileId : String
drawPileId = "draw-pile"


{-| HTML-ID eines Zielpfahl-Elements. -}
pileId : Pile -> String
pileId pile =
    case pile of
        PileLeft   -> "pile-left"
        PileCenter -> "pile-center"
        PileRight  -> "pile-right"


{-| Berechnet den aktuellen CSS-Translate-Offset für die Sliding-Animation.
Interpoliert linear zwischen Ziehstapel-Position und Zielpfahl-Position.
-}
slideOffset : Pile -> PilePositions -> Float -> { dx : Float, dy : Float }
slideOffset dest positions progress =
    let
        to =
            case dest of
                PileLeft   -> positions.left
                PileCenter -> positions.center
                PileRight  -> positions.right
        from = positions.drawPile
    in
    { dx = (to.x - from.x) * progress
    , dy = (to.y - from.y) * progress
    }


{-| Returns the CSS scaleX value for the flip animation.
Shrinking: 1.0 → 0.0, Expanding: 0.0 → 1.0, everything else: 1.0
-}
flipScale : AnimPhase -> Float
flipScale phase =
    case phase of
        Shrinking anim -> 1.0 - anim.progress
        Expanding anim -> anim.progress
        _              -> 1.0


{-| Returns which pile a card at the given deal index belongs to.
Cards are dealt round-robin: index 0 → Left, 1 → Center, 2 → Right, 3 → Left, …
-}
dealDestination : Int -> Pile
dealDestination index =
    case modBy 3 index of
        0 -> PileLeft
        1 -> PileCenter
        _ -> PileRight


{-| Gibt True zurück, wenn alle Karten ausgeteilt wurden.
Das ist der Fall, wenn die Animation im Idle-Zustand ist und der Index
die Gesamtzahl der Karten erreicht oder überschritten hat.
-}
isDealingDone : AnimPhase -> Int -> Bool
isDealingDone phase totalCards =
    case phase of
        Idle index -> index >= totalCards
        _          -> False


{-| Advances the animation by one tick step (1/10 of total phase duration).
- Idle: if cards remain at `index`, starts Shrinking for card at `index`
- Shrinking: increments progress; at >= 1 transitions to Expanding (same card, progress reset)
- Expanding: increments progress; at >= 1 transitions to Sliding (same card, progress reset)
- Sliding: increments progress; at >= 1 transitions to Idle (next index)
-}
tick : List Card -> AnimPhase -> AnimPhase
tick remainingCards phase =
    let
        step = 0.2
    in
    case phase of
        Idle index ->
            case List.drop index remainingCards |> List.head of
                Nothing ->
                    Idle index

                Just card ->
                    Shrinking
                        { index = index
                        , card = card
                        , dest = dealDestination index
                        , progress = 0.0
                        }

        Shrinking anim ->
            let
                newProgress = anim.progress + step
            in
            if newProgress >= 1.0 then
                Expanding { anim | progress = 0.0 }
            else
                Shrinking { anim | progress = newProgress }

        Expanding anim ->
            let
                newProgress = anim.progress + step
            in
            if newProgress >= 1.0 then
                Sliding { anim | progress = 0.0 }
            else
                Expanding { anim | progress = newProgress }

        Sliding anim ->
            let
                newProgress = anim.progress + step
            in
            if newProgress >= 1.0 then
                Idle (anim.index + 1)
            else
                Sliding { anim | progress = newProgress }
