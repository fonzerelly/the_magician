module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)
import Cards exposing (Face (..), Suit(..), Card(..))
import CardTrick exposing (suitName, faceName, cardName)
import Deck exposing (fullDeck, ShuffledDeck, getCards)


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


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----
toImage: Card -> Html Msg
toImage card = img [ src ("/card-deck/" ++ cardName card ++".svg") ] []

view : Model -> Html Msg
view model =
    div []
        [ toImage model.card
        , h1 [] [ text "The Magician" ]
        , div [] (Deck.map toImage model.deck)
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
