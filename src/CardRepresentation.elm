module CardRepresentation exposing (faceName, suitName, cardName, toImage, CardSVGPath)
-- module CardRepresentation exposing (faceName, suitName, cardName, cardToImgTag)
import Cards exposing (Suit(..), Face (..), Card(..))

type alias CardSVGPath = String

faceName : Face -> String
faceName face = case face of
    Ace -> "A"
    King -> "K"
    Queen -> "Q"
    Jack -> "J"
    Ten -> "10"
    Nine -> "9"
    Eight -> "8"
    Seven -> "7"
    Six -> "6"
    Five -> "5"
    Four -> "4"
    Three -> "3"
    Two -> "2"

suitName: Suit -> String
suitName suit = case suit of
    Spades -> "S"
    Clubs -> "C"
    Hearts -> "H"
    Diamonds -> "D"

cardName: Card -> String
cardName card = case card of
    Card s f -> suitName s ++ faceName f
    _ -> "back"

toImage: Card -> CardSVGPath
toImage card = "/card-deck/" ++ cardName card ++".svg"
