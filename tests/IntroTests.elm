module IntroTests exposing (..)

import Test exposing (..)
import Expect
import Intro exposing
    ( IntroPhase(..)
    , tickMillis
    , shimmerOpacity
    , magnusOpacity
    , introText
    , showTapHint
    )


all : Test
all =
    describe "Intro"
        [ describe "tickMillis – Shimmer"
            [ test "Shimmer advances progress proportionally" <|
                \_ ->
                    tickMillis 1000 (Shimmer 0.0)
                        |> Expect.equal (Shimmer 0.5)

            , test "Shimmer transitions to FadeIn when progress reaches 1.0" <|
                \_ ->
                    tickMillis 2000 (Shimmer 0.0)
                        |> Expect.equal (FadeIn 0.0)

            , test "Shimmer transitions to FadeIn when progress overshoots" <|
                \_ ->
                    tickMillis 500 (Shimmer 0.8)
                        |> Expect.equal (FadeIn 0.0)
            ]

        , describe "tickMillis – FadeIn"
            [ test "FadeIn advances progress proportionally" <|
                \_ ->
                    tickMillis 1500 (FadeIn 0.0)
                        |> Expect.equal (FadeIn 0.5)

            , test "FadeIn transitions to WaitForClick when progress reaches 1.0" <|
                \_ ->
                    tickMillis 3000 (FadeIn 0.0)
                        |> Expect.equal WaitForClick

            , test "FadeIn transitions to WaitForClick when progress overshoots" <|
                \_ ->
                    tickMillis 1000 (FadeIn 0.8)
                        |> Expect.equal WaitForClick
            ]

        , describe "tickMillis – WaitForClick and Summoning and Done"
            [ test "WaitForClick stays WaitForClick on tick" <|
                \_ ->
                    tickMillis 1000 WaitForClick
                        |> Expect.equal WaitForClick

            , test "Summoning advances progress proportionally" <|
                \_ ->
                    tickMillis 1000 (Summoning 0.0)
                        |> Expect.equal (Summoning 0.5)

            , test "Summoning transitions to Done when progress reaches 1.0" <|
                \_ ->
                    tickMillis 2000 (Summoning 0.0)
                        |> Expect.equal Done

            , test "Done stays Done on tick" <|
                \_ ->
                    tickMillis 1000 Done
                        |> Expect.equal Done
            ]

        , describe "shimmerOpacity"
            [ test "Shimmer at 0: shimmer not yet visible" <|
                \_ ->
                    shimmerOpacity (Shimmer 0.0)
                        |> Expect.equal 0.0

            , test "Shimmer at 0.5: shimmer half visible" <|
                \_ ->
                    shimmerOpacity (Shimmer 0.5)
                        |> Expect.within (Expect.Absolute 0.001) 0.5

            , test "Shimmer at 1.0: shimmer fully visible" <|
                \_ ->
                    shimmerOpacity (Shimmer 1.0)
                        |> Expect.equal 1.0

            , test "FadeIn at 0: shimmer still fully visible" <|
                \_ ->
                    shimmerOpacity (FadeIn 0.0)
                        |> Expect.equal 1.0

            , test "FadeIn at 0.5: shimmer half faded out" <|
                \_ ->
                    shimmerOpacity (FadeIn 0.5)
                        |> Expect.within (Expect.Absolute 0.001) 0.5

            , test "FadeIn at 1.0: shimmer completely gone" <|
                \_ ->
                    shimmerOpacity (FadeIn 1.0)
                        |> Expect.equal 0.0

            , test "WaitForClick: no shimmer" <|
                \_ ->
                    shimmerOpacity WaitForClick
                        |> Expect.equal 0.0
            ]

        , describe "magnusOpacity"
            [ test "Shimmer phase: magnus invisible" <|
                \_ ->
                    magnusOpacity (Shimmer 0.5)
                        |> Expect.equal 0.0

            , test "FadeIn at 0: magnus still invisible" <|
                \_ ->
                    magnusOpacity (FadeIn 0.0)
                        |> Expect.equal 0.0

            , test "FadeIn at 0.5: magnus half visible" <|
                \_ ->
                    magnusOpacity (FadeIn 0.5)
                        |> Expect.within (Expect.Absolute 0.001) 0.5

            , test "WaitForClick: magnus fully visible" <|
                \_ ->
                    magnusOpacity WaitForClick
                        |> Expect.equal 1.0

            , test "Summoning: magnus fully visible" <|
                \_ ->
                    magnusOpacity (Summoning 0.5)
                        |> Expect.equal 1.0

            , test "Done: magnus fully visible" <|
                \_ ->
                    magnusOpacity Done
                        |> Expect.equal 1.0
            ]

        , describe "introText"
            [ test "Shimmer shows opening question" <|
                \_ ->
                    introText (Shimmer 0.5)
                        |> Expect.equal "Sont Sie bereit für eine Érfahrung der dritten Art? Oui?"

            , test "FadeIn shows mind-reading text" <|
                \_ ->
                    introText (FadeIn 0.5)
                        |> Expect.equal "Lassen Sie misch in Ihren Geist vordringen... Mon Dieu!"

            , test "WaitForClick shows mind-reading text" <|
                \_ ->
                    introText WaitForClick
                        |> Expect.equal "Lassen Sie misch in Ihren Geist vordringen... Mon Dieu!"

            , test "Summoning shows card instruction" <|
                \_ ->
                    introText (Summoning 0.5)
                        |> Expect.equal "Merken Sie sisch eine Karte, die isch Ihnen zeigen verde! Oui?"
            ]

        , describe "showTapHint"
            [ test "WaitForClick shows tap hint" <|
                \_ ->
                    showTapHint WaitForClick
                        |> Expect.equal True

            , test "Shimmer does not show tap hint" <|
                \_ ->
                    showTapHint (Shimmer 0.5)
                        |> Expect.equal False

            , test "FadeIn does not show tap hint" <|
                \_ ->
                    showTapHint (FadeIn 0.5)
                        |> Expect.equal False

            , test "Summoning does not show tap hint" <|
                \_ ->
                    showTapHint (Summoning 0.5)
                        |> Expect.equal False
            ]
        ]
