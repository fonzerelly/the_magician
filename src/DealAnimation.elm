module DealAnimation exposing (Pile(..), dealDestination, AnimPhase(..), AnimData, tick)

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


{-| Returns which pile a card at the given deal index belongs to.
Cards are dealt round-robin: index 0 → Left, 1 → Center, 2 → Right, 3 → Left, …
-}
dealDestination : Int -> Pile
dealDestination index =
    case modBy 3 index of
        0 -> PileLeft
        1 -> PileCenter
        _ -> PileRight


{-| Advances the animation by one tick step (1/10 of total phase duration).
- Idle: if cards remain at `index`, starts Shrinking for card at `index`
- Shrinking: increments progress; at >= 1 transitions to Expanding (same card, progress reset)
- Expanding: increments progress; at >= 1 transitions to Sliding (same card, progress reset)
- Sliding: increments progress; at >= 1 transitions to Idle (next index)
-}
tick : List Card -> AnimPhase -> AnimPhase
tick remainingCards phase =
    let
        step = 0.1
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
