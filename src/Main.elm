module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1)

import Cards exposing (Face (..), Suit(..), Card(..))
import CardRepresentation exposing (cardName, CardsMsg, toHtml)
import Deck exposing (fullDeck, ShuffledDeck, randomDeck, take, map)
import Random
import Debug exposing (log)

type Msg 
    = NoOp | ShuffleDeck ShuffledDeck | CardsMessages CardsMsg

---- MODEL ----

type alias Model =
    { card: Card
    , deck: ShuffledDeck
    }


init : ( Model, Cmd Msg )
init =
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
                dummy = map (log "Drawn " << cardName) drawnCards
            in
            ( { model | deck = drawnCards}, Cmd.none)
       _ -> ( model, Cmd.none )



---- VIEW ----

view : Model -> Html Msg
view model =
    let
        renderCard = Html.map CardsMessages << toHtml
    in
        div []
            [ renderCard model.card
            , h1 [] [ text "The Magician" ]
            , div [] (Deck.map renderCard model.deck)
            ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
