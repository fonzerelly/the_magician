module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)
import Cards exposing (suitName, faceName, Face (..), Suit(..), Card, cardName)


---- MODEL ----

type alias Model =
    {
        card: {suit: Suit, face: Face}
    }


init : ( Model, Cmd Msg )
init =
    ( {card = {suit = Diamond, face = Seven }}, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src ("/card-deck/" ++ cardName model.card ++".svg") ] []
        , h1 [] [ text "The Magician" ]
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
