module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)

-- import Messages exposing (Msg)

import Cards exposing (Face (..), Suit(..), Card(..))
import CardRepresentation exposing (suitName, faceName, cardName, toImage)
import Deck exposing (fullDeck, ShuffledDeck)
-- import Deck exposing (ShuffledDeck(..))
-- import Deck exposing (randomDeck)

type Msg 
    = NoOp

---- MODEL ----

type alias Model =
    { card: Card
    , deck: ShuffledDeck
    }


init : ( Model, Cmd Msg )
init =
    ({ card = Card Spades Ace
     , deck = fullDeck
    }, Cmd.none )



---- UPDATE ----


-- type Msg
--     = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----

view : Model -> Html Msg
view model =
    let 
        render: Card -> Html Msg
        render card = img [src <| toImage card] [] 
    in
    div []
        [ render model.card
        , h1 [] [ text "The Magician" ]
        , div [] (Deck.map render model.deck)
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
