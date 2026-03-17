module Intro exposing
    ( IntroPhase(..)
    , tickMillis
    , shimmerOpacity
    , magnusOpacity
    , introText
    , showTapHint
    )


type IntroPhase
    = Shimmer Float    -- Blauer Schimmer erscheint; progress 0→1 über 2s
    | FadeIn Float     -- Magnus blendet ein, Schimmer verblasst; progress 0→1 über 3s
    | WaitForClick     -- Sequenz fertig, wartet auf Nutzereingabe
    | Summoning Float  -- Magnus-Summoning sichtbar, Kartenhinweis; progress 0→1 über 2s
    | Done             -- Intro abgeschlossen, Spiel startet


shimmerDurationMs : Float
shimmerDurationMs = 2000


fadeInDurationMs : Float
fadeInDurationMs = 3000


summoningDurationMs : Float
summoningDurationMs = 2000


{-| Rückt die Intro-Animation um `deltaMs` Millisekunden weiter.
-}
tickMillis : Float -> IntroPhase -> IntroPhase
tickMillis deltaMs phase =
    case phase of
        Shimmer progress ->
            let next = progress + deltaMs / shimmerDurationMs in
            if next >= 1.0 then FadeIn 0.0 else Shimmer next

        FadeIn progress ->
            let next = progress + deltaMs / fadeInDurationMs in
            if next >= 1.0 then WaitForClick else FadeIn next

        WaitForClick ->
            WaitForClick

        Summoning progress ->
            let next = progress + deltaMs / summoningDurationMs in
            if next >= 1.0 then Done else Summoning next

        Done ->
            Done


{-| Deckkraft des blauen Schimmers.
Blendet in der Shimmer-Phase ein (0→1) und in der FadeIn-Phase aus (1→0).
-}
shimmerOpacity : IntroPhase -> Float
shimmerOpacity phase =
    case phase of
        Shimmer progress -> progress
        FadeIn  progress -> 1.0 - progress
        _                -> 0.0


{-| Deckkraft des Magnus-Bildes.
Während Shimmer unsichtbar, blendet in FadeIn ein (0→1), danach immer 1.
-}
magnusOpacity : IntroPhase -> Float
magnusOpacity phase =
    case phase of
        Shimmer _       -> 0.0
        FadeIn  progress -> progress
        _               -> 1.0


{-| Text für die Sprechblase je nach Intro-Phase.
-}
introText : IntroPhase -> String
introText phase =
    case phase of
        Shimmer _    -> "Sont Sie bereit für eine Érfahrung der dritten Art? Oui?"
        FadeIn _     -> "Lassen Sie misch in Ihren Geist vordringen... Mon Dieu!"
        WaitForClick -> "Gleisch seön sie viele Cart. Bitte merken Sie sisch eine und in welschem Stapel sie ist!"
        Summoning _  -> "Merken Sie sisch eine Karte, die isch Ihnen zeigen verde! Oui?"
        Done        -> ""


{-| Gibt an ob der "Tippen Sie um fortzufahren"-Hinweis angezeigt werden soll.
-}
showTapHint : IntroPhase -> Bool
showTapHint phase =
    phase == WaitForClick
