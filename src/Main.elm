module Main exposing (..)

import Browser
import Html exposing (Html)
import Html.Attributes

import Cards exposing (Face (..), Suit(..), Card(..))
import CardRepresentation exposing (cardName, CardsMsg, toPath)
import Deck exposing (fullDeck, ShuffledDeck, randomDeck, take, map)
import Random

import Element exposing (..)
import Element.Background
import Element.Border

import Time
import Maybe
import MagicTrick exposing (ProperSizedDeck, Game)
import MagicTrick exposing (createProperSizedDeck)
import Deck exposing (getCards)
import MagicTrick exposing (handOut)
import MagicTrick exposing (SlicedDeck(..))
import MagicTrick exposing (unwrapSlicedDeck)

import DealAnimation exposing (Pile(..), AnimPhase(..), AnimData, dealDestination, tick, pileId, drawPileId, PilePositions)
import Browser.Dom
import Task


type alias Flags = ()


type Msg
    = NoOp
    | ShuffleDeck ShuffledDeck
    | Tick Time.Posix
    | InitialTime Time.Posix
    | GotPilePositions (Result Browser.Dom.Error PilePositions)


---- MODEL ----

type alias Model =
    { game : Result String Game
    , drawPile : List Card          -- all 21 cards in deal order
    , dealtLeft : List Card
    , dealtCenter : List Card
    , dealtRight : List Card
    , animPhase : AnimPhase
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
    [ Order 1000 "Sind Sie bereit für eine Erfahrung der dritten Art?"
    , Order 4000 "Merken Sie sich eine Karte"
    ]


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { game = Result.map handOut (createProperSizedDeck [])
      , drawPile = []
      , dealtLeft = []
      , dealtCenter = []
      , dealtRight = []
      , animPhase = Idle 0
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
            in
            ( { model
                | game = theGame
                , drawPile = drawnCards
                , dealtLeft = []
                , dealtCenter = []
                , dealtRight = []
                , animPhase = Idle 0
              }
            , Cmd.none
            )

        InitialTime newTime ->
            ( { model | startTime = newTime }, Cmd.none )

        Tick newTime ->
            let
                timeDelta =
                    Time.posixToMillis newTime - Time.posixToMillis model.startTime

                -- When a Sliding phase completes, commit the card to the pile
                newModel =
                    case model.animPhase of
                        Sliding anim ->
                            if anim.progress + 0.1 >= 1.0 then
                                addToDealt anim.dest anim.card { model | pilePositions = Nothing }
                            else
                                model
                        _ ->
                            model

                newPhase = tick model.drawPile model.animPhase

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
            ( { newModel | animPhase = newPhase, timeDelta = timeDelta }
            , cmd
            )

        GotPilePositions (Ok positions) ->
            ( { model | pilePositions = Just positions }, Cmd.none )

        GotPilePositions (Err _) ->
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


view : Model -> Browser.Document Msg
view model =
    let
        white     = rgb255 255 255 255
        cardCount = List.length model.drawPile

        order =
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

        -- The draw pile box: stacked backs with the flip animation overlaid in front.
        drawPileView =
            if remainingCount > 0 then
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
        [ layout [ curtainTexture ] <|
            column [ height fill, width fill ]
                [ -- instruction text
                  el [ padding 20, width fill ] <|
                      el
                          [ centerX
                          , width (fill |> maximum 900)
                          , Element.Background.color white
                          , Element.Border.rounded 15
                          , padding 10
                          ]
                      <|
                          text order

                -- main stage
                , row [ height fill, width fill ]
                    [ -- magician image
                      column [ height fill, width fill ]
                          [ el [ width fill, height fill ] <|
                              image [ alignBottom, width (fill |> maximum 500) ]
                                  { src = "/src/Background.png", description = "The Magician" }
                          ]

                    -- three destination piles; draw pile sits above the center pile
                    , row [ height fill, width fill, centerX, spacing 10 ]
                        [ column [ height fill, width fill, centerX ]
                            [ el [ centerX, centerY, htmlAttribute (Html.Attributes.id (pileId PileLeft)) ] <| renderPile model.dealtLeft ]
                        , column [ height fill, width fill, centerX ]
                            [ el
                                [ centerX
                                , centerY
                                , above drawPileView
                                , htmlAttribute (Html.Attributes.id (pileId PileCenter))
                                ]
                              <| renderPile model.dealtCenter
                            ]
                        , column [ height fill, width fill, centerX ]
                            [ el [ centerX, centerY, htmlAttribute (Html.Attributes.id (pileId PileRight)) ] <| renderPile model.dealtRight ]
                        ]
                    ]
                ]
        ]
    }


---- PROGRAM ----

subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 50 Tick


main : Program Flags Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
