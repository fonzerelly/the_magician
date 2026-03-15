
# The Magician – Dokumentation

## DealAnimation.elm

### Typen

| Typ | Bedeutung |
|---|---|
| `Pile` | `PileLeft \| PileCenter \| PileRight` — einer der drei Zielpfähle |
| `AnimData` | `{ index, card, dest, progress }` — gemeinsame Felder aller Animationsphasen |
| `AnimPhase` | `Idle Int \| Shrinking AnimData \| Expanding AnimData \| Sliding AnimData` |
| `PilePositions` | `{ drawPile, left, center, right }` — Pixelpositionen aller vier Elemente (zur Laufzeit per Browser.Dom geholt) |

### `dealDestination : Int -> Pile`
Gibt zurück, auf welchen der drei Pfähle die Karte mit dem gegebenen Austeile-Index gelegt wird.
Karten werden reihum verteilt: Index 0 → PileLeft, 1 → PileCenter, 2 → PileRight, 3 → PileLeft, …
Implementiert mit `modBy 3 index`.

### `tick : List Card -> AnimPhase -> AnimPhase`
Rückt die Animation um einen Schritt weiter. Die Zustandsmaschine:

```
Idle index
  → prüft ob drawPile[index] existiert
  → wenn ja: Shrinking (progress=0, card=drawPile[index], dest=dealDestination index)

Shrinking anim
  → progress += 0.1 pro Tick
  → bei progress >= 1.0: Expanding (gleiche Karte, progress=0)

Expanding anim
  → progress += 0.1 pro Tick
  → bei progress >= 1.0: Sliding (gleiche Karte, progress=0)

Sliding anim
  → progress += 0.1 pro Tick
  → bei progress >= 1.0: Idle (index+1)
```

### `flipScale : AnimPhase -> Float`
Gibt den CSS-scaleX-Wert für die Flip-Animation zurück:
- `Shrinking`: `1.0 - progress` (Karte schrumpft von voll auf Linie)
- `Expanding`: `progress` (Karte wächst von Linie auf voll)
- alle anderen Phasen: `1.0`

Wird in der View als `transform: scaleX(...)` mit `transform-origin: center` angewendet.

### `drawPileId : String`
Konstante `"draw-pile"` — HTML-ID des Ziehstapel-Elements. Einzige Quelle der Wahrheit, damit View und Update dieselbe ID verwenden.

### `pileId : Pile -> String`
Gibt die HTML-ID des jeweiligen Zielpfahl-Elements zurück:
- `PileLeft` → `"pile-left"`
- `PileCenter` → `"pile-center"`
- `PileRight` → `"pile-right"`

### `slideOffset : Pile -> PilePositions -> Float -> { dx : Float, dy : Float }`
Berechnet den aktuellen CSS-translate-Offset für die Sliding-Animation durch lineare Interpolation:
- `dx = (ziel.x - ziehstapel.x) * progress`
- `dy = (ziel.y - ziehstapel.y) * progress`

Bei progress=0 ist der Offset (0,0), bei progress=1.0 liegt die Karte exakt auf dem Zielpfahl.

---

## CardRepresentation.elm

### `faceLabel : Face -> String`
Gibt die deutsche Bezeichnung eines Kartenwerts zurück.
Beispiele: `Ace → "Ass"`, `King → "König"`, `Queen → "Dame"`, `Jack → "Bube"`, `Ten → "10"`, usw.

### `suitLabel : Suit -> String`
Gibt die deutsche Bezeichnung einer Kartenfarbe zurück.
`Spades → "Pik"`, `Clubs → "Kreuz"`, `Hearts → "Herz"`, `Diamonds → "Karo"`.

### `cardLabel : Card -> String`
Kombiniert `suitLabel` und `faceLabel` zu einer lesbaren deutschen Kartenbeschreibung.
Beispiel: `Card Hearts Seven → "Herz 7"`, `Card Spades Queen → "Pik Dame"`.
Bei `Back`-Karte: `"Rückseite"`.

Wird in `Main.elm` verwendet um die aufgedeckte Karte am Ende des Tricks anzusagen:
`"Deine Karte war die Herz 7!"` statt des internen Kürzels `"H7"`.

---

## Main.elm – Animationslogik

### `fetchPilePositions : Cmd Msg`
Holt per `Browser.Dom.getElement` die echten Pixelpositionen aller vier Elemente
(`draw-pile`, `pile-left`, `pile-center`, `pile-right`) und schickt das Ergebnis als
`GotPilePositions`-Message zurück. Wird ausgelöst wenn `Idle → Shrinking` übergeht,
damit die Positionen beim Start der Sliding-Phase garantiert verfügbar sind.

### `renderAnimCard : AnimPhase -> Maybe PilePositions -> Element msg`
Zeigt die gerade animierte Karte über dem Ziehstapel:
- **Shrinking**: `back.svg` mit CSS `scaleX(1-progress)`, Mitte fest
- **Expanding**: echte Karte mit CSS `scaleX(progress)`, Mitte fest
- **Sliding**: echte Karte mit CSS `translate(dx, dy)` basierend auf `slideOffset`; wenn Positionen noch nicht geladen → keine Transform
- **Idle**: unsichtbar

### `animProgress : AnimPhase -> Float`
Hilfsfunktion — gibt den `progress`-Wert der aktuellen Phase zurück (oder 0.0 für Idle).

### `addToDealt : Pile -> Card -> Model -> Model`
Hängt eine fertig animierte Karte an den richtigen Zielpfahl im Model an.
Wird im `Tick`-Handler aufgerufen, sobald eine Sliding-Phase abgeschlossen ist.

### `drawPileSize : AnimPhase -> Int -> Int`
Berechnet wie viele Karten noch im Ziehstapel liegen. Wird verwendet um den Stapel
auszublenden wenn alle 21 Karten ausgeteilt sind.

### `renderPile : List Card -> Element msg`
Zeigt die oberste Karte eines Zielpfahls. Bei leerem Pfahl wird ein unsichtbarer Platzhalter
gleicher Größe gerendert, damit das Layout stabil bleibt.

---

## MagicTrick.elm – Fehleranalyse (ADR 0002)

### `errorCandidates : List UserSelection -> ProperSizedDeck -> List Card`
Berechnet alle Karten die der Algorithmus gefunden hätte, wenn der User in genau einer
der drei Runden einen anderen Stapel gewählt hätte.

Vorgehen: Für jede der 3 Runden werden die 2 alternativen Wahlen ausprobiert (6 Varianten
gesamt). Jede Variante simuliert das komplette Spiel mit der einen geänderten Wahl und
liefert das `readMind`-Ergebnis. Die Resultate werden dedupliziert zurückgegeben
(Duplikate entstehen wenn verschiedene Fehlerwahlen zum selben Ergebnis führen).

Wichtige Einschränkung (dokumentiert in ADR 0002): Ein echter Einzel-Fehler in Runde k
führt dazu, dass auch Runde k+1 anders geklickt wird als beim idealen Pfad ("adaptives
Tracking"). Der tatsächliche und der ideale Pfad können daher an 2 Stellen abweichen,
obwohl nur 1 Fehler gemacht wurde. `errorCandidates` prüft nur 1-Stellen-Abweichungen
und deckt daher nicht alle echten Fehler ab.

Wird in `Main.elm` nach Abschluss von Runde 3 ausgeführt. Ergebnis aktuell per
`Debug.log` in der Browser-Konsole ausgegeben (GUI-Realisierung noch offen).

### `suitMatchRatio : Suit -> List Card -> Float`
Gibt den Anteil der Fehlerkandidaten zurück, die die genannte Farbe haben.
Wertebereich: `0.0` (kein Kandidat passt) bis `1.0` (alle Kandidaten haben diese Farbe).

Eingabe:
- `suit` — die Farbe die der User nach einem "Nein" nennt (♠ ♥ ♦ ♣)
- `candidates` — die Ausgabe von `errorCandidates`

Wird für die spätere Score-Berechnung benötigt:
`score = w_suit * suitMatchRatio + w_timing * normalizedReactionTime`

`Back`-Karten in der Kandidatenliste zählen nicht als Match (haben keine Farbe).
Bei leerer Kandidatenliste wird `0.0` zurückgegeben.

---

## Main.elm – ADR-0002-Tracking

### Model-Felder `initialDeck` und `userSelections`
Zwei neue Felder im Model halten die für `errorCandidates` nötigen Daten vor:

- `initialDeck : Maybe ProperSizedDeck` — das Deck vor Runde 1, gesetzt in `ShuffleDeck`,
  danach nie mehr verändert
- `userSelections : List UserSelection` — wächst pro Runde um eine Wahl, wird in
  `UserPickedPile` befüllt

Beide Felder werden bei jedem `ShuffleDeck` (Neustart) zurückgesetzt.
