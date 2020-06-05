module CardTrick exposing (faceName, suitName, cardName)
import Cards exposing (Suit(..), Face (..), Card(..))
-- module Cards exposing (Suit (..), Face(..), Card, faceName, suitName, cardName, createDeck, toFace,faceToInt, Deck)
-- type Suit = Spade | Diamond | Heart | Clubs
-- type Face = Ace  | King  | Queen | Jack | Ten
--     | Nine | Eight | Seven | Six  | Five | Four | Three | Two

-- type alias Card = { suit:Suit
--                   , face:Face 
--                   }


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

--cardName : Card->String
--cardName card = case card.face of

-- createDeck: Card
-- createDeck = Card

-- type alias Deck = List Card

-- fullSuit : Suit -> List Card
-- fullSuit suit =
--     [ Ace, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King ]
--     |> List.map (Card suit) 

-- createDeck : Deck
-- createDeck =
--     [ Spade, Diamond, Clubs, Heart ]
--     |> List.map fullSuit 
--     |> List.concat 

-- -- helper used in test
-- toFace : Int -> Maybe Face
-- toFace number =
--     case number of
--         1 -> Just Ace
--         2 -> Just Two
--         3 -> Just Three
--         4 -> Just Four
--         5 -> Just Five
--         6 -> Just Six
--         7 -> Just Seven
--         8 -> Just Eight
--         9 -> Just Nine
--         10 -> Just Ten
--         11 -> Just Jack
--         12 -> Just Queen
--         13 -> Just King
--         _ -> Nothing

-- faceToInt : Face -> Int
-- faceToInt face =
--     case face of
--         Ace -> 1
--         Two -> 2
--         Three -> 3
--         Four -> 4
--         Five -> 5
--         Six -> 6
--         Seven -> 7
--         Eight -> 8
--         Nine -> 9
--         Ten -> 10
--         Jack -> 11
--         Queen -> 12
--         King -> 13
