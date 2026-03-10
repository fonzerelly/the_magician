
# The Magician – Dokumentation

## DealAnimation.elm

### `dealDestination : Int -> Pile`
Gibt zurück, auf welchen der drei Stapel die Karte mit dem gegebenen Austeile-Index gelegt wird.
Karten werden reihum verteilt: Index 0 → PileLeft, 1 → PileCenter, 2 → PileRight, 3 → PileLeft, …
Implementiert mit `modBy 3 index`.

### `tick : List Card -> AnimPhase -> AnimPhase`
Rückt die Animation um einen Schritt (1/10 einer Phase) weiter. Die Zustands-Maschine:

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
  → bei progress >= 1.0: Idle (index+1), Karte wird dem Zielpfad gutgeschrieben
```

### Typen

| Typ | Bedeutung |
|---|---|
| `Pile` | `PileLeft \| PileCenter \| PileRight` — einer der drei Zielpfade |
| `AnimData` | `{ index, card, dest, progress }` — gemeinsame Felder aller Animationsphasen |
| `AnimPhase` | `Idle Int \| Shrinking AnimData \| Expanding AnimData \| Sliding AnimData` |

---

## Main.elm – Animationslogik

### `renderAnimCard : AnimPhase -> Element msg`
Zeigt die Karte, die gerade animiert wird, über dem Kartenstapel:
- **Shrinking**: `back.svg` wird schmäler (`width = cardMaxWidth * (1 - progress)`)
- **Expanding**: die echte Karte wird breiter (`width = cardMaxWidth * progress`)
- **Idle / Sliding**: nichts (die Karte fliegt schon zum Stapel)

### `renderFlyingCard : AnimPhase -> Element msg`
Zeigt während der Sliding-Phase die Karte in voller Breite. Wird von `highlightFor` ergänzt,
das den Zielstapel mit einem gelben Leuchten hervorhebt.

### `addToDealt : Pile -> Card -> Model -> Model`
Hängt eine fertig animierte Karte an den richtigen Zielstapel im Model an.
Wird im `Tick`-Handler aufgerufen, sobald eine `Sliding`-Phase abgeschlossen ist.

### `drawPileSize : AnimPhase -> Int -> Int`
Berechnet wie viele Karten noch im Abhebstapel liegen (wird zum Ausblenden des Stapels
verwendet, wenn alle Karten ausgeteilt sind).
