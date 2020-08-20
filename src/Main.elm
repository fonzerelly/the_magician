module Main exposing (..)

import Browser
import Html exposing (Html)

import Cards exposing (Face (..), Suit(..), Card(..))
import CardRepresentation exposing (cardName, CardsMsg, toHtml)
import Deck exposing (fullDeck, ShuffledDeck, randomDeck, take, map)
import Random
import Debug exposing (log)

import Element exposing (..)
import Element.Background

type alias Flags = ()

type Msg 
    = NoOp | ShuffleDeck ShuffledDeck | CardsMessages CardsMsg

---- MODEL ----

type alias Model =
    { card: Card
    , deck: ShuffledDeck
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ({ card = Card Spades Ace
     , deck = fullDeck
    }, Random.generate ShuffleDeck randomDeck )



---- UPDATE ----


-- type Msg
--     = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
       ShuffleDeck newDeck -> 
            let
                drawnCards = take 9 newDeck
                dummy = Deck.map (log "Drawn " << cardName) drawnCards
            in
            ( { model | deck = drawnCards}, Cmd.none)
       _ -> ( model, Cmd.none )

red = rgb255 255 0 0
darkRed = rgb255 128 0 0
green = rgb255 0 255 0

curtain cols = List.range 1 cols
    |> List.map (\i -> if (modBy 2 i == 0) then red else darkRed)
---- VIEW ----

view : Model -> Browser.Document Msg
view model =
    let
        renderCard = Element.html << Html.map CardsMessages << toHtml
        back = Element.Background.gradient { angle = pi/2, steps = curtain 50}
        c = Card Spades Ace
    in
        { title = "The Magician"
        , body = [ layout [] <| column [width fill, height fill] 
                    [ row [ width fill
                          ] [ el [centerX, spacingXY 60 60] <| text "Anweisungen"]
                    , row [ width fill, height fill, back, alignBottom ] 
                        [ el [alignRight, width fill, height fill ] <| image [ height fill ] {src = "Background.png", description = "The Magician"}
                        , el [ alignLeft, width fill,height fill] <| renderCard <| Card Spades Ace
                        ]
                    -- , column [ width <| , Element.Background.color <| green  ] 
                    --     [ el [ alignLeft ] <| text "Cards"

                    --     ]
                    ]
                 ]

        -- , body = [ div [] [ renderCard model.card
        --                 , h1 [] [ text "The Magician" ]
        --                 , div [] (Deck.map renderCard model.deck)
        --                 ]
        --          ]
        }
        


---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
