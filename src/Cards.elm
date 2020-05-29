module Cards exposing (Suit (..), Face(..), Card, faceName, suitName)
type Suit = Spade | Diamond | Heart | Clubs
type Face = Ace  | King  | Queen | Jack | Ten
    | Nine | Eight | Seven | Six  | Five | Four | Three | Two

type alias Card = { suit:Suit
                  , face:Face 
                  }


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
    Spade -> "S"
    Clubs -> "C"
    Heart -> "H"
    Diamond -> "D"

--cardName : Card->String
--cardName card = case card.face of

-- createDeck: Card
-- createDeck = Card