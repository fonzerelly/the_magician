module MagicTrick exposing ( Game, UserSelection(..), ProperSizedDeck, SlicedDeck(..)
                           , length, downSize, handOut, mergeGame, readMind, createProperSizedDeck
                           , representProperSizedDeck, representGame, unwrapSlicedDeck, unwrapProperSizedDeck
                           , errorCandidates, suitMatchRatio
                           )
import Cards exposing (Card(..), Face(..), Suit(..))
import List
import CardRepresentation exposing (cardName)
import Array
import Result


type alias Game = { left:  SlicedDeck
                  , center: SlicedDeck
                  , right: SlicedDeck
                  }

type alias RepresentativeGame = { left: List String
                                , center: List String
                                , right: List String
                                }


type alias Deck = List Card

type ProperSizedDeck = ProperSizedDeck Deck
type SlicedDeck = SlicedDeck Deck

type UserSelection = UserTookLeft | UserTookCenter | UserTookRight

createProperSizedDeck: Deck -> Result String ProperSizedDeck 
createProperSizedDeck deck =
    let
        deckSize = List.length deck

        isMultipleOfThree: Int -> Bool
        isMultipleOfThree size = modBy 3 size |> (==) 0
        
        isOdd: Int -> Bool
        isOdd size = modBy 2 size |> (==) 1

        isValid: Int -> Bool
        isValid size = isOdd size && isMultipleOfThree size
    in
        if isValid deckSize then
            deck |> ProperSizedDeck |> Result.Ok
        else
            if isOdd deckSize then
                Result.Err "A deck needs to be dividable by three!"
            else
                Result.Err "A deck needs to be odd!"

downSize: Deck -> Deck
downSize shuffledDeck =
    let
        decksize = List.length shuffledDeck
        multipleOfThree = div decksize 3

        amount = case modBy 2 multipleOfThree of
            0 -> (multipleOfThree - 1) * 3
            _ -> decksize

        shrinkedDeck = case decksize of 
            0 -> Nothing
            1 -> Nothing
            2 -> Nothing
            _ -> shuffledDeck |> List.take amount |> ProperSizedDeck |> Just
    in
        shuffledDeck |> List.take amount

length: ProperSizedDeck -> Int
length properSizedDeck = case properSizedDeck of
   ProperSizedDeck deck -> List.length deck

cardOfTuple: (Int, Card) -> Card
cardOfTuple (_, card) = card

isNthOf: Int -> (Int, a) -> Bool
isNthOf n (index, _) = n == modBy 3 index

toIndexedCard: Int -> Card -> (Int, Card)
toIndexedCard index card = (index, card)

div : Int -> Int -> Int
div a b = floor (toFloat a / toFloat b)

unwrapProperSizedDeck : ProperSizedDeck -> List Card
unwrapProperSizedDeck deck = case deck of
   ProperSizedDeck d -> d

representProperSizedDeck : ProperSizedDeck -> List String
representProperSizedDeck deck = deck |> unwrapProperSizedDeck |> List.map cardName

-- rename to stringify Game
representGame: Game -> RepresentativeGame
representGame game = { left = game |> .left |> unwrapSlicedDeck |> List.map cardName
                     , center = game |> .center |> unwrapSlicedDeck |> List.map cardName
                     , right = game |> .right |> unwrapSlicedDeck |> List.map cardName
                     }

unwrapSlicedDeck : SlicedDeck -> List Card
unwrapSlicedDeck deck = case deck of
   SlicedDeck d -> d

handOut : ProperSizedDeck -> Game
handOut deck =
    let
        indexedCards = deck |> unwrapProperSizedDeck |> List.indexedMap toIndexedCard
        everyFirst = 0 |> isNthOf
        everySecond = 1 |> isNthOf
        everyThird = 2 |> isNthOf

    in
    { left = indexedCards |> List.filter everyFirst |> List.map cardOfTuple  |> SlicedDeck
    , center = indexedCards |> List.filter everySecond |> List.map cardOfTuple |> SlicedDeck
    , right = indexedCards |> List.filter everyThird |> List.map cardOfTuple |> SlicedDeck
    }

-- Das Problem ist, dass merge selber wieder ein Result zurück gibt. 
-- Dadurch kommt es zu einem Result Result...
-- Wo müsste also ein Result.andThen zum einsatz kommen?
mergeGame : UserSelection -> Game -> Result String ProperSizedDeck
mergeGame selection game =
    let
        listOfLeft = .left >> unwrapSlicedDeck
        listOfCenter = .center >> unwrapSlicedDeck
        listOfRight = .right >> unwrapSlicedDeck
    in
        case selection of
            UserTookLeft -> Result.andThen createProperSizedDeck (Result.Ok (listOfCenter game ++ listOfLeft game ++ listOfRight game))
            UserTookRight -> Result.andThen createProperSizedDeck (Result.Ok (listOfLeft game ++ listOfRight game ++ listOfCenter game))
            UserTookCenter -> Result.andThen createProperSizedDeck (Result.Ok (listOfLeft game ++ listOfCenter game ++ listOfRight game))

readMind : ProperSizedDeck -> Maybe Card
readMind deck =
    let
       arrayOfCards = deck |> unwrapProperSizedDeck |> Array.fromList
       indexToPick = div (Array.length arrayOfCards) 2
    in
    arrayOfCards |> Array.get indexToPick


-- Berechnet alle alternativen Karten die der Algorithmus gefunden hätte,
-- wenn der User in genau einer Runde einen anderen Stapel gewählt hätte.
-- Gibt deduplizierte Liste zurück (Duplikate sind möglich wenn verschiedene
-- Fehlerwahlen zum selben Ergebnis führen).
errorCandidates : List UserSelection -> ProperSizedDeck -> List Card
errorCandidates selections initialDeck =
    let
        alternativesFor : UserSelection -> List UserSelection
        alternativesFor sel =
            case sel of
                UserTookLeft   -> [ UserTookCenter, UserTookRight ]
                UserTookCenter -> [ UserTookLeft,   UserTookRight ]
                UserTookRight  -> [ UserTookLeft,   UserTookCenter ]

        replaceAt : Int -> a -> List a -> List a
        replaceAt idx newVal list =
            List.indexedMap (\i v -> if i == idx then newVal else v) list

        -- Simuliert ein komplettes Spiel mit einer gegebenen Wahlliste
        simulateGame : List UserSelection -> Maybe Card
        simulateGame sels =
            let
                step : UserSelection -> Maybe ProperSizedDeck -> Maybe ProperSizedDeck
                step sel maybeDeck =
                    maybeDeck
                        |> Maybe.map handOut
                        |> Maybe.andThen (\game -> mergeGame sel game |> Result.toMaybe)
            in
            List.foldl step (Just initialDeck) sels
                |> Maybe.andThen readMind

        -- Alle 6 Varianten: pro Runde je 2 alternative Wahlen
        variantSelections : List (List UserSelection)
        variantSelections =
            selections
                |> List.indexedMap (\roundIdx sel ->
                    alternativesFor sel
                        |> List.map (\alt -> replaceAt roundIdx alt selections)
                )
                |> List.concat

        addIfNew : Card -> List Card -> List Card
        addIfNew card acc =
            if List.member card acc then acc else acc ++ [ card ]
    in
    variantSelections
        |> List.filterMap simulateGame
        |> List.foldl addIfNew []


-- Anteil der Kandidaten die die genannte Farbe haben (0.0 = kein Match, 1.0 = alle).
-- Eingabe: die Farbe die der User nennt + die Fehlerkandidaten-Liste aus errorCandidates.
suitMatchRatio : Suit -> List Card -> Float
suitMatchRatio suit candidates =
    let
        total = List.length candidates

        suitOf card = case card of
            Card s _ -> Just s
            Back     -> Nothing

        matches =
            candidates
                |> List.filter (\card -> suitOf card == Just suit)
                |> List.length
    in
    if total == 0 then
        0.0
    else
        toFloat matches / toFloat total