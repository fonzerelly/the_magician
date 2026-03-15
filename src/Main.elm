module Main exposing (..)

import Browser
import Html exposing (Html)
import Html.Attributes

import Cards exposing (Face (..), Suit(..), Card(..))
import CardRepresentation exposing (cardName, cardLabel, CardsMsg, toPath)
import Deck exposing (fullDeck, ShuffledDeck, randomDeck, take, map)
import Random

import Element exposing (..)
import Element.Background
import Element.Border
import Element.Events
import Element.Font

import Time
import Maybe
import MagicTrick exposing (ProperSizedDeck, Game, UserSelection(..))
import MagicTrick exposing (createProperSizedDeck, handOut, mergeGame, readMind, unwrapProperSizedDeck)
import Deck exposing (getCards)
import MagicTrick exposing (SlicedDeck(..))
import MagicTrick exposing (unwrapSlicedDeck)

import DealAnimation exposing (Pile(..), AnimPhase(..), AnimData, dealDestination, tick, pileId, drawPileId, PilePositions)
import Browser.Dom
import Task
import Intro exposing (IntroPhase(..), tickMillis, shimmerOpacity, magnusOpacity, introText, showTapHint)


type alias Flags = ()


type AppPhase
    = Intro IntroPhase
    | Dealing
    | WaitingForSelection
    | ShowingResult Card


type Msg
    = NoOp
    | ShuffleDeck ShuffledDeck
    | Tick Time.Posix
    | InitialTime Time.Posix
    | GotPilePositions (Result Browser.Dom.Error PilePositions)
    | UserPickedPile UserSelection
    | UserTapped


---- MODEL ----

type alias Model =
    { game : Result String Game
    , drawPile : List Card          -- all 21 cards in deal order
    , dealtLeft : List Card
    , dealtCenter : List Card
    , dealtRight : List Card
    , animPhase : AnimPhase
    , appPhase : AppPhase
    , round : Int                   -- aktuelle Runde (1–3)
    , timeDelta : Int
    , startTime : Time.Posix
    , pilePositions : Maybe PilePositions
    }


type alias Order =
    { timestamp : Int
    , message : String
    }


orders : List Order
orders =
    [ Order 1000 "Oui, oui... isch sehe alles, mon ami!"
    , Order 4000 "Merken Sie sisch eine Karte, s'il vous plaît!"
    ]


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { game = Result.map handOut (createProperSizedDeck [])
      , drawPile = []
      , dealtLeft = []
      , dealtCenter = []
      , dealtRight = []
      , animPhase = Idle 0
      , appPhase = Intro (Shimmer 0.0)
      , round = 1
      , timeDelta = 0
      , startTime = Time.millisToPosix 0
      , pilePositions = Nothing
      }
    , Cmd.batch
        [ Random.generate ShuffleDeck randomDeck
        , Task.perform InitialTime Time.now
        ]
    )


---- UPDATE ----

addToDealt : Pile -> Card -> Model -> Model
addToDealt pile card model =
    case pile of
        PileLeft   -> { model | dealtLeft   = model.dealtLeft   ++ [ card ] }
        PileCenter -> { model | dealtCenter = model.dealtCenter ++ [ card ] }
        PileRight  -> { model | dealtRight  = model.dealtRight  ++ [ card ] }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShuffleDeck newDeck ->
            let
                drawnCards = take 21 newDeck |> getCards
                properSizedDeck = createProperSizedDeck drawnCards
                theGame = Result.map handOut properSizedDeck

                -- Beim initialen Laden (Intro läuft noch) die Phase nicht überschreiben.
                -- Beim Neustart nach ShowingResult direkt in Dealing.
                newAppPhase =
                    case model.appPhase of
                        Intro _ -> model.appPhase
                        _       -> Dealing
            in
            ( { model
                | game = theGame
                , drawPile = drawnCards
                , dealtLeft = []
                , dealtCenter = []
                , dealtRight = []
                , animPhase = Idle 0
                , appPhase = newAppPhase
                , round = 1
              }
            , Cmd.none
            )

        InitialTime newTime ->
            ( { model | startTime = newTime }, Cmd.none )

        Tick newTime ->
            case model.appPhase of
                Intro introPhase ->
                    let
                        newIntroPhase = tickMillis 50 introPhase
                        newAppPhase =
                            if newIntroPhase == Done then Dealing
                            else Intro newIntroPhase
                    in
                    ( { model | appPhase = newAppPhase }, Cmd.none )

                _ ->
                    let
                        timeDelta =
                            Time.posixToMillis newTime - Time.posixToMillis model.startTime

                        newPhase = tick model.drawPile model.animPhase

                        -- Wenn die Sliding-Phase abgeschlossen ist (Übergang Sliding → Idle),
                        -- wird die Karte fest zum Zielpfahl hinzugefügt.
                        -- Wir prüfen den Phasenwechsel statt progress + 0.1, damit diese
                        -- Logik unabhängig von der konkreten Schrittgröße in DealAnimation bleibt.
                        newModel =
                            case ( model.animPhase, newPhase ) of
                                ( Sliding anim, Idle _ ) ->
                                    addToDealt anim.dest anim.card { model | pilePositions = Nothing }
                                _ ->
                                    model

                        newAppPhase =
                            case model.appPhase of
                                ShowingResult _ ->
                                    model.appPhase
                                _ ->
                                    if DealAnimation.isDealingDone newPhase (List.length model.drawPile) then
                                        WaitingForSelection
                                    else
                                        Dealing

                        -- Problem: Browser.Dom.getElement ist asynchron. Das Ergebnis kommt erst im
                        -- *nächsten* Update-Zyklus an (via GotPilePositions). Wenn man die Positionen
                        -- erst beim Start der Sliding-Phase anfordert, sind sie beim ersten Sliding-Tick
                        -- noch nicht da → die Karte springt von (0,0) los statt vom richtigen Startpunkt.
                        --
                        -- Lösung: Positionen eine Phase früher anfordern — beim Übergang Idle→Shrinking.
                        -- Die Shrinking- und Expanding-Phasen dauern je mehrere Ticks (100 ms-Intervall),
                        -- sodass GotPilePositions garantiert eintrifft, bevor Sliding beginnt.
                        cmd =
                            case ( model.animPhase, newPhase ) of
                                ( Idle _, Shrinking _ ) ->
                                    fetchPilePositions
                                _ ->
                                    Cmd.none
                    in
                    ( { newModel | animPhase = newPhase, appPhase = newAppPhase, timeDelta = timeDelta }
                    , cmd
                    )

        GotPilePositions (Ok positions) ->
            ( { model | pilePositions = Just positions }, Cmd.none )

        GotPilePositions (Err _) ->
            ( model, Cmd.none )

        UserPickedPile selection ->
            case model.game of
                Err _ ->
                    ( model, Cmd.none )

                Ok game ->
                    case mergeGame selection game of
                        Err _ ->
                            ( model, Cmd.none )

                        Ok mergedDeck ->
                            if model.round < 3 then
                                -- Noch nicht fertig: neu austeilen für die nächste Runde
                                let
                                    newDrawPile = unwrapProperSizedDeck mergedDeck
                                    newGame     = handOut mergedDeck
                                in
                                ( { model
                                    | game          = Ok newGame
                                    , drawPile      = newDrawPile
                                    , dealtLeft     = []
                                    , dealtCenter   = []
                                    , dealtRight    = []
                                    , animPhase     = Idle 0
                                    , appPhase      = Dealing
                                    , round         = model.round + 1
                                    , pilePositions = Nothing
                                  }
                                , Cmd.none
                                )
                            else
                                -- Runde 3 abgeschlossen: Karte aufdecken
                                case readMind mergedDeck of
                                    Nothing ->
                                        ( model, Cmd.none )

                                    Just card ->
                                        ( { model | appPhase = ShowingResult card }
                                        , Cmd.none
                                        )

        UserTapped ->
            case model.appPhase of
                Intro WaitForClick ->
                    ( { model | appPhase = Intro (Summoning 0.0) }, Cmd.none )
                ShowingResult _ ->
                    ( model, Random.generate ShuffleDeck randomDeck )
                _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


fetchPilePositions : Cmd Msg
fetchPilePositions =
    Task.map4
        (\drawEl leftEl centerEl rightEl ->
            { drawPile = { x = drawEl.element.x,   y = drawEl.element.y }
            , left     = { x = leftEl.element.x,   y = leftEl.element.y }
            , center   = { x = centerEl.element.x, y = centerEl.element.y }
            , right    = { x = rightEl.element.x,  y = rightEl.element.y }
            }
        )
        (Browser.Dom.getElement drawPileId)
        (Browser.Dom.getElement (pileId PileLeft))
        (Browser.Dom.getElement (pileId PileCenter))
        (Browser.Dom.getElement (pileId PileRight))
        |> Task.attempt GotPilePositions


---- VIEW ----

green : Color
green = rgb255 0 255 0


curtain : Int -> List Color
curtain cols =
    let
        red     = rgb255 255 0 0
        darkRed = rgb255 128 0 0
    in
    List.range 1 cols
        |> List.map
            (\i ->
                if modBy 2 i == 0 then
                    red
                else
                    darkRed
            )


curtainTexture : Attribute msg
curtainTexture =
    Element.Background.gradient { angle = pi / 2, steps = curtain 50 }


cardMaxWidth : Int
cardMaxWidth = 120

cardHeight : Int
cardHeight = 170


{-| Renders a card image at full width, centered. Used for dealt piles. -}
renderCard : Card -> Element msg
renderCard card =
    image
        [ width (px cardMaxWidth)
        , height (px cardHeight)
        , centerX
        ]
        { src = toPath card, description = cardName card }


{-| Renders the flip animation over the draw pile.
Uses CSS scaleX with transform-origin center — Mitte bleibt fest, Karte schrumpft/wächst horizontal.
-}
renderAnimCard : AnimPhase -> Maybe PilePositions -> Element msg
renderAnimCard phase mPositions =
    let
        scale = DealAnimation.flipScale phase

        flipCard card =
            el
                [ width (px cardMaxWidth)
                , height (px cardHeight)
                , Html.Attributes.style "transform" ("scaleX(" ++ String.fromFloat scale ++ ")") |> htmlAttribute
                , Html.Attributes.style "transform-origin" "center" |> htmlAttribute
                ]
            <|
                image [ width fill, height fill ]
                    { src = toPath card, description = cardName card }

        slideCard card dest =
            case mPositions of
                Nothing ->
                    image [ width (px cardMaxWidth), height (px cardHeight) ]
                        { src = toPath card, description = cardName card }
                Just positions ->
                    let
                        offset = DealAnimation.slideOffset dest positions (animProgress phase)
                    in
                    el
                        [ width (px cardMaxWidth)
                        , height (px cardHeight)
                        , Html.Attributes.style "transform"
                            ("translate(" ++ String.fromFloat offset.dx ++ "px, " ++ String.fromFloat offset.dy ++ "px)")
                            |> htmlAttribute
                        ]
                    <|
                        image [ width fill, height fill ]
                            { src = toPath card, description = cardName card }
    in
    case phase of
        Shrinking _ ->
            flipCard Back

        Expanding anim ->
            flipCard anim.card

        Sliding anim ->
            slideCard anim.card anim.dest

        _ ->
            none


animProgress : AnimPhase -> Float
animProgress phase =
    case phase of
        Shrinking anim -> anim.progress
        Expanding anim -> anim.progress
        Sliding anim   -> anim.progress
        Idle _         -> 0.0


{-| Renders the top card of a dealt pile (or an empty placeholder). -}
renderPile : List Card -> Element msg
renderPile pile =
    case List.reverse pile |> List.head of
        Nothing ->
            el [ width (px cardMaxWidth), height (px cardHeight) ] none

        Just topCard ->
            renderCard topCard


{-| How many cards are still in the draw pile. -}
drawPileSize : AnimPhase -> Int -> Int
drawPileSize phase total =
    case phase of
        Idle index     -> total - index
        Shrinking anim -> total - anim.index
        Expanding anim -> total - anim.index - 1
        Sliding anim   -> total - anim.index - 1


{-| Erzeugt die Attribute für einen Zielpfahl.
Im WaitingForSelection-Zustand wird ein Klick-Handler und ein Cursor-Pointer hinzugefügt.
-}
pileAttrs : Pile -> AppPhase -> List (Attribute Msg)
pileAttrs pile appPhase =
    let
        baseAttrs =
            [ centerX
            , centerY
            , htmlAttribute (Html.Attributes.id (pileId pile))
            ]

        selection =
            case pile of
                PileLeft   -> UserTookLeft
                PileCenter -> UserTookCenter
                PileRight  -> UserTookRight
    in
    case appPhase of
        WaitingForSelection ->
            baseAttrs ++
                [ Element.Events.onClick (UserPickedPile selection)
                , htmlAttribute (Html.Attributes.style "cursor" "pointer")
                ]
        Dealing ->
            baseAttrs

        ShowingResult _ ->
            baseAttrs

        Intro _ ->
            baseAttrs


view : Model -> Browser.Document Msg
view model =
    let
        white     = rgb255 255 255 255
        cardCount = List.length model.drawPile

        order =
            case model.appPhase of
                Intro introPhase ->
                    introText introPhase

                WaitingForSelection ->
                    "Velchen Stapel? Montrez-moi! S'il vous plaît!"

                ShowingResult card ->
                    "Magnifique! Ihre Karte var die " ++ cardLabel card ++ "! C'est incroyable, non?"

                Dealing ->
                    orders
                        |> List.reverse
                        |> List.filter (\o -> .timestamp o < model.timeDelta)
                        |> List.head
                        |> Maybe.map .message
                        |> Maybe.withDefault ""

        remainingCount = drawPileSize model.animPhase cardCount

        -- Zwei Back-Karten leicht versetzt — simuliert einen Kartenstapel.
        stackedBack =
            el
                [ width (px cardMaxWidth)
                , height (px cardHeight)
                , inFront
                    (image
                        [ width (px cardMaxWidth)
                        , height (px cardHeight)
                        , moveRight 3
                        , moveDown 3
                        ]
                        { src = toPath Back, description = "Kartenstapel" }
                    )
                ]
                (image
                    [ width (px cardMaxWidth), height (px cardHeight) ]
                    { src = toPath Back, description = "Kartenstapel" }
                )

        -- Die Animation läuft als inFront-Overlay über dem Nachziehstapel.
        -- Problem: drawPileSize gibt für Expanding/Sliding der letzten Karte 0 zurück,
        -- weil die Karte schon "abgezogen" gilt — aber die Animation läuft noch.
        -- Daher: Nachziehstapel solange zeigen wie eine Animation aktiv ist (nicht Idle).
        isAnimating =
            case model.animPhase of
                Idle _ -> False
                _      -> True

        drawPileView =
            if remainingCount > 0 || isAnimating then
                el
                    [ width (px cardMaxWidth)
                    , height (px cardHeight)
                    , centerX
                    , inFront (renderAnimCard model.animPhase model.pilePositions)
                    , htmlAttribute (Html.Attributes.id drawPileId)
                    ]
                    stackedBack
            else
                el [ width (px cardMaxWidth), height (px cardHeight) ] none

    in
    { title = "The Magician"
    , body =
        [ layout
            (curtainTexture
                :: (case model.appPhase of
                        Intro WaitForClick ->
                            [ Element.Events.onClick UserTapped
                            , htmlAttribute (Html.Attributes.style "cursor" "pointer")
                            ]
                        _ ->
                            []
                   )
            ) <|
            column [ height fill, width fill ]
                [ -- instruction text
                  el [ padding 20, width fill ] <|
                      el
                          [ centerX
                          , width (fill |> maximum 900)
                          , Element.Background.color white
                          , Element.Border.rounded 15
                          , padding 20
                          , Element.below
                              (el [ alignLeft, moveRight 60 ] <|
                                  html
                                      (Html.div
                                          [ Html.Attributes.style "width" "0"
                                          , Html.Attributes.style "height" "0"
                                          , Html.Attributes.style "border-left" "20px solid transparent"
                                          , Html.Attributes.style "border-right" "20px solid transparent"
                                          , Html.Attributes.style "border-top" "25px solid white"
                                          ]
                                          []
                                      )
                              )
                          ]
                      <|
                          column [ spacing 8, width fill ]
                              [ text order
                              , if showTapHint (case model.appPhase of
                                                    Intro p -> p
                                                    _       -> Done)
                                then
                                    el [ centerX, Element.Font.italic, Element.Font.size 14 ]
                                        (text "Tippen Sie, s'il vous plaît")
                                else
                                    none
                              ]

                -- main stage
                , row [ height fill, width fill ]
                    [ -- magician image
                      column [ height fill, width fill ]
                          [ el [ width fill, height fill ] <|
                              -- Shimmer-Layer (blaues Leuchten) und Magnus-Bild übereinander
                              el
                                  [ width (fill |> maximum 500)
                                  , alignBottom
                                  , inFront
                                      (case model.appPhase of
                                          Intro introPhase ->
                                              el
                                                  [ width fill
                                                  , height fill
                                                  , htmlAttribute (Html.Attributes.style "opacity"
                                                      (String.fromFloat (shimmerOpacity introPhase)))
                                                  , htmlAttribute (Html.Attributes.style "filter"
                                                      ( "brightness(0)"
                                                      ++ " drop-shadow(0 0 12px #0080ff)"
                                                      ++ " drop-shadow(0 0 25px #0060ff)"
                                                      ++ " drop-shadow(0 0 50px #0040ff)"
                                                      ))
                                                  ]
                                              <|
                                                  image [ width fill, alignBottom ]
                                                      { src = "src/magnus-states/magus_init.png"
                                                      , description = ""
                                                      }
                                          _ ->
                                              none
                                      )
                                  ]
                              <|
                                  image
                                      [ alignBottom
                                      , width fill
                                      , htmlAttribute (Html.Attributes.style "opacity"
                                          (case model.appPhase of
                                              Intro introPhase -> String.fromFloat (magnusOpacity introPhase)
                                              _                -> "1"
                                          ))
                                      ]
                                      { src =
                                          case model.appPhase of
                                              Intro (Summoning _) -> "src/magnus-states/magnus-summoning.png"
                                              Intro _             -> "src/magnus-states/magus_init.png"
                                              _                   -> "src/magnus-states/magnus-summoning.png"
                                      , description = "The Magician"
                                      }
                          ]

                    , case model.appPhase of
                        Intro _ ->
                            none

                        ShowingResult card ->
                            -- Karte mindestens doppelt so groß (2.5x) zentriert auf der rechten Seite
                            -- Klick startet neues Spiel
                            el
                                [ height fill
                                , width fill
                                , centerX
                                , Element.Events.onClick UserTapped
                                , htmlAttribute (Html.Attributes.style "cursor" "pointer")
                                ]
                            <|
                                column [ centerX, centerY, spacing 16 ]
                                    [ image
                                        [ centerX
                                        , width  (px (cardMaxWidth * 5 // 2))
                                        , height (px (cardHeight  * 5 // 2))
                                        ]
                                        { src = toPath card, description = cardName card }
                                    , el [ centerX, Element.Font.italic, Element.Font.size 14, Element.Font.color white ]
                                        (text "Tippen für neues Spiel")
                                    ]

                        _ ->
                            -- three destination piles; draw pile sits above the center pile
                            row [ height fill, width fill, centerX, spacing 10 ]
                                [ column [ height fill, width fill, centerX ]
                                    [ el (pileAttrs PileLeft model.appPhase) <| renderPile model.dealtLeft ]
                                , column [ height fill, width fill, centerX ]
                                    [ el ([ above drawPileView ] ++ pileAttrs PileCenter model.appPhase) <| renderPile model.dealtCenter ]
                                , column [ height fill, width fill, centerX ]
                                    [ el (pileAttrs PileRight model.appPhase) <| renderPile model.dealtRight ]
                                ]
                    ]
                ]
        ]
    }


---- PROGRAM ----

subscriptions : Model -> Sub Msg
subscriptions model =
    case model.appPhase of
        Intro _ -> Time.every 50 Tick
        Dealing -> Time.every 30 Tick
        _       -> Sub.none


main : Program Flags Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
