module Main exposing (..)

import Browser
import Html exposing (Html)

import Cards exposing (Face (..), Suit(..), Card(..))
import CardRepresentation exposing (cardName, CardsMsg, toPath)
import Deck exposing (fullDeck, ShuffledDeck, randomDeck, take, map)
import Random
import Debug exposing (log)

import Element exposing (..)
import Element.Background
import Element.Border

import Time
import Task
import Maybe
import MagicTrick exposing (ProperSizedDeck, Game)
import MagicTrick exposing (createProperSizedDeck)
import Deck exposing (getCards)
import MagicTrick exposing (handOut)
import MagicTrick exposing (SlicedDeck(..))
import MagicTrick exposing (unwrapSlicedDeck)

type alias Flags = ()


type DrawState = Left | Center | Right

type Msg 
    = NoOp 
    | ShuffleDeck ShuffledDeck 
    | CardsMessages CardsMsg 
    | Tick Time.Posix
    | InitialTime Time.Posix

---- MODEL ----

type alias Model =
    { card: Card
    , game: Result String Game
    , visualizedGame: Result String Game
    , drawState: DrawState
    , timeDelta: Int
    , startTime: Time.Posix
    }

type alias Order =
    { timestamp : Int
    , message: String
    }

orders: List Order
orders = [ Order 1000 "Sind Sie bereit für eine Erfahrung der dritten Art?"
         , Order 4000 "Merken Sie sich eine Karte"
         ]

init : Flags -> ( Model, Cmd Msg )
init _ =
    let
        aGame = Result.map handOut (createProperSizedDeck [])
    in
    ({ card = Card Spades Ace
     , game = aGame
     , visualizedGame = aGame
     , drawState = Right
     , timeDelta = 0
     , startTime = Time.millisToPosix 0
    }, Cmd.batch [ Random.generate ShuffleDeck randomDeck
                 , Task.perform InitialTime Time.now
                 ] 
    )




---- UPDATE ----


-- type Msg
--     = NoOp


-- ToDO
-- do not store deck of cards, store a game
-- based on tick show game cards in app

switchDrawStateOnTimeDelta: Int -> Model -> Model
switchDrawStateOnTimeDelta timeDelta model = 
    let
        newDrawState = case .drawState model of
           Left -> Center
           Center -> Right
           Right -> Left
    in
        { model | drawState = newDrawState }

selectStackByDrawState: DrawState -> Game -> SlicedDeck
selectStackByDrawState drawState game = case drawState of
   Left -> .left game
   Center -> .center game
   Right -> .right game

newGame: DrawState -> Game -> SlicedDeck -> Game
newGame drawState game deck = case drawState of
    Left -> {game | left = deck}
    Center -> {game | center = deck}
    Right -> {game | right = deck}
-- removeCardFromGame: DrawState -> Game -> Game

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShuffleDeck newDeck ->
            let
                drawnCards = take 21 newDeck
                dummy = Deck.map (log "Drawn " << cardName) drawnCards
                properSizedDeck = drawnCards
                    |> getCards
                    |> createProperSizedDeck
                theGame = Result.map handOut properSizedDeck
            in
            ( { model | game = theGame, visualizedGame = theGame
              }, Cmd.none)
        InitialTime newTime ->
            ( { model | startTime = newTime}, Cmd.none)
        Tick newTime ->
            let
                timeDelta = Time.posixToMillis newTime - Time.posixToMillis model.startTime
                newModel = switchDrawStateOnTimeDelta timeDelta model

                currentDrawState = .drawState model
                currentGame = .visualizedGame model

                newVisualizedGame = Result.map 
                    (\cg -> cg |> selectStackByDrawState currentDrawState >> tailOfDeck >> newGame currentDrawState cg) 
                    currentGame

                tailOfDeck: SlicedDeck -> SlicedDeck
                tailOfDeck (SlicedDeck deck) = List.tail deck |> Maybe.withDefault [] |> SlicedDeck
            in
                ( { newModel | timeDelta = timeDelta, visualizedGame = newVisualizedGame}, Cmd.none)
        _ -> ( model, Cmd.none )

green = rgb255 0 255 0

curtain cols = 
    let
        red = rgb255 255 0 0
        darkRed = rgb255 128 0 0
    in
    List.range 1 cols
        |> List.map (
            \i -> if (modBy 2 i == 0) then 
                    red 
                else 
                    darkRed
        )

curtainTexture = Element.Background.gradient { angle = pi/2, steps = curtain 50 }

---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    let
        renderCard size card = image [ alignBottom, width (fill|> maximum size), centerY ] {src = toPath card, description = cardName card}
        cardSize = 200
        magician = image [ alignBottom, width (fill|> maximum 500) ] {src = "Background.png", description = "The Magician"}
        beBlue = Element.Background.color <| Element.rgb 0 0 1.0
        white = rgb255 255 255 255
        order = orders
            |> List.reverse
            |> List.filter (\o -> .timestamp o < model.timeDelta)
            |> List.head
            |> Maybe.map .message
            |> Maybe.withDefault ""

        takeCardByDrawState: DrawState -> Card
        takeCardByDrawState drawState = 
            let
                f = case drawState of
                    Left -> .left
                    Center -> .center
                    Right -> .right
                game = .visualizedGame model
            in
                case game of
                    Result.Ok validGame -> validGame |> f |> unwrapSlicedDeck |> List.head |> Maybe.withDefault Back
                    Result.Err _ -> Back

    in
        { title = "The Magician"
        , body = [ layout [curtainTexture] <| column [height fill, width fill] 
            [ el [padding 20, width fill] <| el [centerX, width (fill |> maximum 900), Element.Background.color white, Element.Border.rounded 15, padding 10] <| text order
            ,  row [height fill, width fill]
                [ column [height fill, width fill] 
                    [ el [ width fill, height fill] <| magician
                    ]
                , row [height fill, width fill, centerX] 
                    [ el [width fill, height fill] <| renderCard cardSize <| takeCardByDrawState Left
                    , el [width fill, height fill] <| renderCard cardSize <| takeCardByDrawState Center
                    , el [width fill, height fill] <| renderCard cardSize <| takeCardByDrawState Right
                    ]
                ]
            ]
        ]
-- [ layout [] <| column [width fill, height fill] 
--                     [ row [] [ el [centerX, spacingXY 60 60] <| text "Anweisungen"]
--                     , row [ width fill, height fill, back] 
--                         [ el [width fill, height fill] <| image [ height fill, alignBottom ] {src = "Background.png", description = "The Magician"}
--                         , el [ alignLeft, width fill,height fill] <| renderCard <| Card Spades Ace
--                         ]
--                     ]
--                  ]
        -- , body = [ div [] [ renderCard model.card
        --                 , h1 [] [ text "The Magician" ]
        --                 , div [] (Deck.map renderCard model.deck)
        --                 ]
        --          ]
        }
        


---- PROGRAM ----
subscriptions: Model -> Sub Msg
subscriptions model = Time.every 1000 Tick

main : Program Flags Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
