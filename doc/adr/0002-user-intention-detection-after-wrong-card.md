# ADR 0002: Erkennung der User-Intention bei "Das war nicht meine Karte"

**Datum:** 2026-03-13
**Status:** Draft – noch nicht entschieden

## Kontext

Am Ende des Tricks zeigt der Magier die identifizierte Karte. Wir wollen den User fragen:
*"War das Ihre Karte?"* mit den Antworten Ja / Nein.

Ein "Nein" kann zwei grundlegend verschiedene Ursachen haben:

1. **Echter Fehler (Case 1):** Der User war mit dem Spielablauf überfordert und hat in
   mindestens einer Runde versehentlich den falschen Stapel angeklickt. Der Algorithmus
   hat daher eine andere Karte gefunden als die gemerkete.

2. **Absichtliches Testen (Case 2):** Der Algorithmus hat die richtige Karte gefunden,
   aber der User klickt "Nein" um das Spiel auf die Probe zu stellen oder aus Spaß.

## Motivation

Viel Spaß am Spiel entsteht durch Experimentieren und den Charakter des Magiers:
er gibt den großen Geheimnisvollen, ist aber gleichzeitig klein, rechthaberisch und
aufbrausend. Wenn wir Case 1 vs. Case 2 unterscheiden können, kann der Magier
unterschiedlich reagieren — z.B. ein Bild zeigen wie er aus der Haut fährt wenn er
getrollt wird. Das gibt dem Spiel Charakter und reizt den User, verschiedene
Spielausgänge zu provozieren (Replayability).

## Problem

Aus den reinen Spieldaten (3 Stapelwahlen + gefundene Karte) lassen sich diese beiden
Fälle **nicht direkt unterscheiden**, weil wir nie wissen, welche Karte der User
tatsächlich im Kopf hatte.

## Grundlage: Die 6 Fehlerkandidaten

Da der Algorithmus deterministisch ist, lässt sich für jede mögliche Falsch-Wahl
berechnen, welche Karte stattdessen gefunden worden wäre. Bei 3 Runden und je 2
alternativen Stapelwahlen ergeben sich immer genau 6 "Fehlerkandidaten":
3 Runden × 2 Alternativen = 6 alternative Spielverläufe, jeder mit genau 1 Ergebnis.

Jeder Kandidat ist die Antwort auf: *"Was hätte der Algorithmus gefunden, wenn der User
in genau einer Runde einen anderen Stapel gewählt hätte?"*

Die Fehlerkandidaten können erst **nach Abschluss aller 3 Runden** berechnet werden,
da dafür sowohl das initiale Deck als auch alle 3 tatsächlichen Wahlen des Users
bekannt sein müssen. Der Berechnungszeitpunkt ist also: unmittelbar nachdem der User
"Nein" geklickt hat.

**Konsequenz für das Model:** Das initiale Deck darf nicht weggeworfen werden.
Es reicht, folgendes im Model zu halten:

- Das ursprüngliche `ProperSizedDeck` (vor Runde 1)
- Die `List UserSelection` mit allen 3 Wahlen

Damit lässt sich jeder der 6 alternativen Spielverläufe vollständig rekonstruieren.
Die sauberere Alternative wäre, die 3 Zwischenergebnisse nach jedem `mergeGame`
zu speichern — das ist jedoch redundant, da sie aus den obigen zwei Werten
ableitbar sind.

### Konkretes Beispiel (9 Karten)

**Initiales Deck nach Shuffle:**
```
♥Q  ♥K  ♠8  ♦A  ♣3  ♥7  ♠2  ♦K  ♣9
 0    1    2    3    4    5    6    7    8
```

**Runde 1 — handOut (round-robin):**
```
Left   (0,3,6): ♥Q  ♦A  ♠2
Center (1,4,7): ♥K  ♣3  ♦K
Right  (2,5,8): ♠8  ♥7  ♣9
```
User wählt **Left** → merge: Center ++ **Left** ++ Right
```
♥K ♣3 ♦K | ♥Q ♦A ♠2 | ♠8 ♥7 ♣9
```

**Runde 2 — handOut:**
```
Left   (0,3,6): ♥K  ♥Q  ♠8
Center (1,4,7): ♣3  ♦A  ♥7
Right  (2,5,8): ♦K  ♠2  ♣9
```
User wählt **Center** → merge: Left ++ **Center** ++ Right
```
♥K ♥Q ♠8 | ♣3 ♦A ♥7 | ♦K ♠2 ♣9
```

**Runde 3 — handOut:**
```
Left   (0,3,6): ♥K  ♣3  ♦K
Center (1,4,7): ♥Q  ♦A  ♠2
Right  (2,5,8): ♠8  ♥7  ♣9
```
User wählt **Center** → merge: Left ++ **Center** ++ Right
```
♥K ♣3 ♦K | ♥Q ♦A ♠2 | ♠8 ♥7 ♣9
            ^Index 4^
```
**readMind → ♦A** ✓

**Die 6 Fehlervarianten** — jeweils eine Wahl geändert, Rest identisch:

| Variante | Geändert   | R1     | R2     | R3     | readMind |
| ---      | ---        | ---    | ---    | ---    | ---      |
| Actual   | —          | Left   | Center | Center | **♦A**   |
| V1       | R1→Center  | Center | Center | Center | **♣3**   |
| V2       | R1→Right   | Right  | Center | Center | **♥7**   |
| V3       | R2→Left    | Left   | Left   | Center | **♥Q**   |
| V4       | R2→Right   | Left   | Right  | Center | **♠2**   |
| V5       | R3→Left    | Left   | Center | Left   | **♣3** ← Duplikat von V1 |
| V6       | R3→Right   | Left   | Center | Right  | **♥7** ← Duplikat von V2 |

**Befund:** V5 und V6 liefern dieselben Karten wie V1 und V2 — es gibt also nur
**4 eindeutige Fehlerkandidaten**: ♣3, ♥7, ♥Q, ♠2. "Bis zu 6" ist korrekt,
Duplikate sind möglich. Bei 9 Karten decken 4 Kandidaten bereits 50% der
verbleibenden Karten ab — das Signal ist schwach.

**Bekannte Schwäche — Aussagekraft abhängig von Deck-Größe:**
Die 6 Kandidaten bleiben immer 6, egal wie viele Karten im Deck. Der Lösungsraum
schrumpft aber mit dem Deck:

| Deck-Größe | Fehlerkandidaten | Verbleibende Karten | Abdeckung |
| ---        | ---              | ---                 | ---       |
| 21 Karten  | 6                | 20                  | 30%       |
| 9 Karten   | 6                | 8                   | 75%       |

Bei 21 Karten ist 30% Abdeckung noch ein brauchbares Signal. Bei kleinen Decks
wird der Ansatz fast wertlos. **Noch nicht abschließend bewertet.**

## Analysierte UX-Varianten nach einem "Nein"

### Variante A: Alle 21 Karten zur Auswahl zeigen

Der User wählt seine Karte aus dem gesamten Deck.

- Wählt er eine der 6 Fehlerkandidaten → **Case 1**
- Wählt er eine andere Karte → **Case 2**

**Problem:** Zu unübersichtlich, vor allem auf kleinen Bildschirmen.

### Variante B: Die 6 Kandidaten direkt zeigen

*"Ist Ihre Karte darunter?"* — User sieht nur die 6 möglichen Fehlerkarten.

- Klickt er eine davon → **Case 1**
- Klickt er "Nein" → **Case 2**

**Problem:** Ein Troll klickt einfach nochmal "Nein". Wir wissen wieder nichts.
Außerdem könnte das Zeigen der 6 Karten den Mechanismus zu sehr enthüllen.

### Variante C: Zweistufige Auswahl (Farbe → Wert)

Erst Farbe wählen (♠ ♥ ♦ ♣ = 4 Buttons), dann Kartenwert (A 2 … K = 13 Buttons).
Maximal 2 Klicks, definitive Antwort.

- Genannte Karte ist ein Fehlerkandidat → **Case 1**
- Genannte Karte ist kein Fehlerkandidat → **Case 2**

**Nachteil:** 2 Interaktionsschritte, fühlt sich etwas nach Verhör an.

### Variante D: Nur die Farbe fragen (probabilistisch)

4 Buttons (♠ ♥ ♦ ♣). Minimale Reibung. Kein definitives Ergebnis, aber ein
Wahrscheinlichkeitssignal basierend auf der Farbverteilung unter den 6 Kandidaten.

Beispiel: Kandidaten sind 3× ♥, 2× ♠, 1× ♦, 0× ♣.
- User sagt ♥ → hohes Vertrauen in Case 1 (3 von 6 passen)
- User sagt ♣ → kein Kandidat passt → sehr wahrscheinlich Case 2

**Vorteil:** Der Magier kann mit abgestufter Sicherheit reagieren —
*"Ah, très intéressant..."* bei hoher Wahrscheinlichkeit vs.
*"Vous me mentez!"* bei sehr unwahrscheinlicher Farbangabe.

**Schwäche:** Wenn die 6 Kandidaten alle 4 Farben gleichmäßig abdecken, ist das
Signal schwach. Die Qualität des Signals variiert je nach konkretem Spielverlauf.

**Idee: Gezinktes Spiel durch Seed-Manipulation**

Wenn wir den Zufalls-Seed so wählen würden, dass die Farbverteilung der 6 Kandidaten
möglichst ungleich ist, wäre Variante D immer aussagekräftig. Diese Idee scheitert
jedoch an zwei Problemen:

1. Die Farbverteilung der 6 Kandidaten hängt nicht nur vom initialen Shuffle ab,
   sondern auch von den 3 tatsächlichen Wahlen des Users. Ein "guter" Seed für
   die Wahlen [Left, Center, Right] kann bei [Right, Right, Left] eine gleichmäßige
   Verteilung ergeben. Um alle 27 möglichen Wahlkombinationen (3³) abzudecken,
   bräuchte man einen Seed der für *jede* Kombination eine schiefe Verteilung
   garantiert — das ist kaum erreichbar.

2. Würde man auf eine kleine Menge "guter" Seeds einschränken, würde ein User der
   mehrfach spielt sehr schnell denselben Kartenverlauf wiedersehen. Das fällt auf.

**Konsequenz:** Der Seed bleibt vollständig zufällig. Stattdessen wird die
**Reaktion des Magiers** an die tatsächliche Signalstärke des jeweiligen Spielverlaufs
angepasst:

- Farbverteilung der 6 Kandidaten ist schief → Farbangabe des Users ist aussagekräftig
  → Magier reagiert mit hoher Sicherheit (empört oder verständnisvoll)
- Farbverteilung ist gleichmäßig → Signal schwach → Magier reagiert mit
  gespielter Ungewissheit oder Skepsis

Die Manipulation betrifft also nicht die Nachfrage, sondern die **Intensität der
Magier-Reaktion**.

## Weitere Ansätze

### Timing-Daten bei Stapelwahl

Die Zeit zwischen Anzeige der Stapel und Klick des Users wird pro Runde gemessen.
Sehr schnelle Klicks (<500ms) deuten auf Unachtsamkeit oder Trolling hin;
längere Überlegezeiten (2–3s) sprechen für echtes Mitspielen.

**Konkretes Implementierungskonzept:**

Der Zeitstempel wird in zwei Momenten erfasst:

1. **Wenn die Stapel sichtbar werden** (d.h. wenn der App-Zustand nach `ShowingStacks`
   wechselt): `Task.perform StackShownAt Time.now` → speichert `Time.Posix` im Model.

2. **Wenn der User einen Stapel klickt**: `Task.perform (StackClickedAt selection) Time.now`
   → speichert Klick-Zeitstempel und berechnet die Differenz.

**Model-Erweiterung:**

```elm
type alias RoundTiming =
    { shownAt : Time.Posix
    , clickedAt : Time.Posix
    }

-- Im Model:
roundTimings : List RoundTiming   -- wächst pro Runde, max 3 Einträge
stackShownAt : Maybe Time.Posix   -- Zwischenspeicher bis zum Klick
```

Nach allen 3 Runden liegt eine `List RoundTiming` mit 3 Einträgen vor.
Die Differenz `clickedAt - shownAt` ergibt die Reaktionszeit pro Runde in Millisekunden.

**Auswertungslogik (Heuristik):**

```
scoreRound : RoundTiming -> Int
scoreRound t =
    let ms = Time.posixToMillis t.clickedAt - Time.posixToMillis t.shownAt
    in
    if ms < 500 then -1      -- verdächtig schnell (Troll oder unachtsam)
    else if ms > 5000 then 1  -- echte Überlegung
    else 0                    -- neutral

timingScore : List RoundTiming -> Int
timingScore = List.sum << List.map scoreRound
```

Ein `timingScore >= 2` ist ein starkes Signal für echtes Mitspielen (Case 1);
ein `timingScore <= -2` verstärkt den Troll-Verdacht (Case 2).

**Umsetzungsaufwand:** Gering. Keine neue Bibliothek nötig, `Time.now` via Task
ist Standard-Elm. Nur als ergänzende Heuristik nutzbar, nicht als alleiniges Signal.

## Kombination der beiden Signale

### Warum sie sich gegenseitig stärken

Die entscheidende Eigenschaft: die beiden Signale messen **verschiedene, weitgehend
unabhängige Dimensionen** desselben Verhaltens.

- **Fehlerkandidaten** = *Was* hat der User letztlich angegeben? (Output)
- **Timing** = *Wie* hat der User während des Spiels geklickt? (Prozess)

Das ist keine Redundanz, sondern Orthogonalität: Jemand der beim Timing "auffällig"
ist, muss nicht zwingend beim Kandidaten-Signal auffällig sein — und umgekehrt.
Damit liefert jeder Treffer neue Information, statt dasselbe nochmal zu messen.

### Warum das Timing schwer zu fälschen ist

Ein Troll der bewusst "Nein" klickt, hat beim Timing in der Regel **nicht aktiv
manipuliert** — er hat einfach schnell geklickt, weil ihm das Spiel egal ist.
Das Timing-Signal entsteht *während des Spiels*, bevor der User weiß dass es
ausgewertet wird. Es ist damit ein passives Verhaltensmuster, kein aktiver Einwand.

Ein echter Case-1-Spieler hingegen hat seine Karte im Kopf, überlegt vor jedem Klick
("ist das der richtige Stapel?") und klickt deshalb langsamer — ohne es zu wollen
oder zu wissen.

### Das Troll-Dilemma: Schwierig beide Signale gleichzeitig zu faken

Ein cleverer Troll könnte theoretisch beide Signale manipulieren:
- Absichtlich langsam klicken (timing faken)
- Danach gezielt eine der 6 Fehlerkandidaten-Karten nennen (output faken)

Das setzt aber voraus, dass er den Algorithmus kennt *und* aktiv plant.
Für den Durchschnittsnutzer der einfach "Nein" trollt, ist das unrealistisch.

### Kombinationsmatrix

Die vier Quadranten visualisiert — X-Achse: Klickgeschwindigkeit, Y-Achse: Fehlerkandidat:

```mermaid
quadrantChart
    title Intention-Erkennung
    x-axis "Schnell geklickt" --> "Langsam geklickt"
    y-axis "Kein Fehlerkandidat" --> "Ist Fehlerkandidat"
    quadrant-1 Echter Fehler - hohe Sicherheit
    quadrant-2 Fehler - schwaches Signal
    quadrant-3 Troll - schwaches Signal
    quadrant-4 Troll - hohe Sicherheit

    Typischer Case-1-Spieler: [0.75, 0.85]
    Verwirrt aber ehrlich: [0.3, 0.75]
    Cleverer Troll: [0.7, 0.15]
    Typischer Troll: [0.2, 0.2]
```

**Lesehinweis:**
- Quadrant oben-rechts (Fehlerkandidat ✓ + langsam): Magier reagiert verständnisvoll
- Quadrant oben-links (Fehlerkandidat ✓ + schnell): Magier reagiert konziliant, aber leicht verwundert
- Quadrant unten-rechts (kein Kandidat + langsam): Magier reagiert verwirrt, räumt Fehler ein
- Quadrant unten-links (kein Kandidat + schnell): Magier reagiert empört — "Sie schummeln!"

Die **Beispielpunkte** zeigen typische Nutzerprofile:

- *Typischer Case-1-Spieler*: Hat wirklich überlegt (langsam) und nennt eine Fehlerkandidaten-Karte
- *Verwirrt aber ehrlich*: Hat etwas gehetzt geklickt, aber die Karte passt zu einem Fehlerkandidat
- *Cleverer Troll*: Hat sich Zeit gelassen um unverdächtig zu wirken, nennt aber keine Fehlerkarte
- *Typischer Troll*: Hat schnell geklickt und nennt eine beliebige Karte

Bei `timingScore == 0` (neutral, 500ms–5s) entscheidet allein der Fehlerkandidat-Befund,
aber die Magier-Reaktion fällt moderater aus als in den Extremfällen.

### Warum das Signal nie perfekt sein kann — und das in Ordnung ist

Selbst mit beiden Signalen gibt es keine 100%-Sicherheit. Das ist kein Bug,
sondern ein Feature: Ein Magier der manchmal irrt ist glaubwürdiger als einer
der immer recht hat. Die Unsicherheit gehört zum Charakter.

Das Ziel ist nicht Klassifikationsgenauigkeit, sondern eine Reaktion die im
Kontext *plausibel* wirkt und Replayability erzeugt — beide Signale zusammen
reichen dafür aus.

### Sitzungshistorie

Wer in mehreren Spielen hintereinander "Nein" klickt, ist mit hoher
Wahrscheinlichkeit ein Troll. Erfordert Persistenz (localStorage oder Backend) —
aktuell nicht im Scope.

## Erweiterung: 6-Feld und 9-Feld Raster

Das 4-Quadranten-Modell vereinfacht den timingScore auf "schnell vs. langsam" und
ignoriert die natürliche Neutral-Zone. Beide Signale haben jedoch eine sinnvolle
dritte Stufe — was zu verfeinerten Rastern führt.

### Option A: 6-Feld Raster (Variante C + Timing, 2x3)

Fehlerkandidat bleibt binär (Ja/Nein). Der timingScore wird in 3 Stufen aufgeteilt:
schnell (<500ms), neutral (500ms–5s), langsam (>5s). Ergibt 2×3 = 6 Felder.

Die Punkte im Diagramm repräsentieren die sechs Zonen — je eine pro Feld:

```mermaid
quadrantChart
    title 6-Feld Raster - Option A
    x-axis "Schnell geklickt" --> "Langsam geklickt"
    y-axis "Kein Fehlerkandidat" --> "Ist Fehlerkandidat"
    quadrant-1 Echter Fehler - hohe Sicherheit
    quadrant-2 Fehler - schwaches Signal
    quadrant-3 Troll - schwaches Signal
    quadrant-4 Troll - hohe Sicherheit

    Ja und schnell: [0.15, 0.78]
    Ja und neutral: [0.5, 0.78]
    Ja und langsam: [0.85, 0.78]
    Nein und schnell: [0.15, 0.22]
    Nein und neutral: [0.5, 0.22]
    Nein und langsam: [0.85, 0.22]
```

Die senkrechte Mittellinie des Diagramms bei x=0.5 trennt schnell/langsam —
die neutrale Zone liegt auf dieser Linie und ist der Mehrwert gegenüber 4 Quadranten.

| Feld | Bedingung | Magier-Reaktion |
|---|---|---|
| 1 | Fehlerkandidat + Schnell | Skeptisch konziliant: "Ich glaube Ihnen... vielleicht" |
| 2 | Fehlerkandidat + Neutral | Freundlich hilfsbereit |
| 3 | Fehlerkandidat + Langsam | Sehr verstaendnisvoll, fast entschuldigend |
| 4 | Kein Kandidat + Schnell | Empoert: "Sie schummeln!" |
| 5 | Kein Kandidat + Neutral | Leicht gereizt, misstrauisch |
| 6 | Kein Kandidat + Langsam | Verwirrt, raumt Fehler ein |

**Benoetigt: 6 Reaktionsbilder des Magiers**

### Option B: 9-Feld Raster (Variante D + Timing, 3x3)

Voraussetzung: Variante D (User nennt nur die Farbe). Das Fehlerkandidat-Signal
wird probabilistisch auf 3 Stufen aufgeteilt je nachdem wie viele der 6 Kandidaten
die genannte Farbe haben:

- **Starker Match**: 3–6 Kandidaten haben diese Farbe
- **Schwacher Match**: 1–2 Kandidaten haben diese Farbe
- **Kein Match**: 0 Kandidaten haben diese Farbe

```mermaid
block-beta
  columns 4
  space FastCol["Schnell"] NeutralCol["Neutral"] SlowCol["Langsam"]
  StrongRow["Starker Match"] A["skeptisch\naber offen"] B["verstaendnisvoll"] C["sehr\nverstaendnisvoll"]
  WeakRow["Schwacher Match"] D["sehr skeptisch"] E["ratlos"] F["verwundert"]
  NoneRow["Kein Match"] G["empoert - Troll"] H["gereizt"] I["verwirrt\nfassungslos"]
```

| | Schnell | Neutral | Langsam |
|---|---|---|---|
| **Starker Match** | Skeptisch: "Haben Sie sich beeilt?" | Verstaendnisvoll | Sehr verstaendnisvoll |
| **Schwacher Match** | Sehr skeptisch: "Zufall!" | Ratlos, unsicher | Leicht verwundert |
| **Kein Match** | "Sie luegen mich an!" | Gereizt | "Das ist inexplicable..." |

**Benoetigt: 9 Reaktionsbilder** (einige ahnliche Felder konnten ein Bild teilen, minimal ~7)

---

## Entscheidungshilfe: Welches Raster wahlen?

### Gesamtbedarf an Magier-Bildern

Neben den Reaktionsbildern braucht der Magier Bilder fur den normalen Spielverlauf:

| Phase | Anzahl | Beschreibung |
|---|---|---|
| Intro / Beschwörung | 1–2 | Magier tritt auf, geheimnisvoll |
| Runde 1 austeilen | 1 | Konzentrierter Blick |
| Runde 2 austeilen | 1 | Zuversichtlich |
| Runde 3 austeilen | 1 | Dramatisch |
| Enthüllung (Treffer) | 1 | Triumphierend |
| **Spielphasen-Subtotal** | **5–6** | |

Gesamtbedarf inklusive Reaktionsbilder:

| Raster | Reaktionsbilder | Gesamtbilder | Trennscharf generierbar? |
|---|---|---|---|
| 4 Quadranten | 4 | ~9–10 | Ja — 4 klare Grundemotionen |
| **6-Feld (Option A)** | **6** | **~11–12** | **Ja — praktische Obergrenze** |
| 9-Feld (Option B) | 9 (min. ~7) | ~14–15 | Bedingt — einige Felder zu ahnlich |

**Warum 6 die praktische Grenze ist:** GPT Image kann einen Charakter konsistent
halten, aber subtile Abstufungen ("leicht gereizt" vs. "mittel gereizt") werden
bildlich kaum unterscheidbar. Grundemotionen (Freude, Empörung, Verwirrtheit,
Skepsis) plus je eine abgestufte Variante davon ergeben 6 Bilder die sich
voneinander klar abgrenzen. Darüber wird es unzuverlässig.

### Vergleich der Optionen

| Kriterium | 4 Quadranten | 6-Feld (Option A) | 9-Feld (Option B) |
|---|---|---|---|
| UX fur User | exakte Karte nennen | exakte Karte nennen | nur Farbe nennen |
| Algorithmus-Aufwand | gering | gering (+neutral case) | mittel (Farbverteilung berechnen) |
| Neue Elm-Typen | keine | keine | `SuitMatchStrength` |
| Reaktionsbilder | 4 | 6 | 9 (~7) |
| Gesamtbilder | ~9 | ~11 | ~14 |
| Signal-Qualitat | gut | gut | variiert je nach Spielverlauf |
| Charakter-Reichtum | mittel | gut | am reichsten |

### Empfehlung

**6-Feld mit Variante C** ist der beste Kompromiss:

- Kein algorithmischer Mehraufwand gegenuber 4 Quadranten — der timingScore hat
  ohnehin 3 natürliche Stufen, es braucht nur einen dritten Pattern-Match-Fall
- 6 Reaktionsbilder sind mit GPT Image zuverlässig trennscharf generierbar
- Variante C (exakte Karte nennen) liefert ein definitives Signal das zum Charakter
  des selbstsicheren Magiers passt — er muss nicht raten, er weiss es
- Gesamtbedarf ~11–12 Bilder ist in einer kontrollierten Generierungsrunde machbar

Das 9-Feld lohnt sich nur wenn man Variante D aus UX-Gruenden bevorzugt (weniger
Reibung fur den User). Dann aber konsequent, weil nur Variante D das 3-stufige
Fehlerkandidat-Signal liefert das das 9er-Raster rechtfertigt.

## Empfehlung (noch offen)

Noch keine endgültige Entscheidung. Engste Kandidaten:

- **6-Feld + Variante C** — bester Kompromiss aus Aufwand, Bildqualitat und Signal
- **9-Feld + Variante D** — reichstes Charakterspiel, aber mehr Aufwand und
  Bildgenerierung an der Belastungsgrenze

## Konsequenzen (wenn umgesetzt)

- Neue Funktion `errorCandidates : List UserSelection -> ProperSizedDeck -> List Card`
  in `MagicTrick.elm`
- Neuer AppPhase-Zustand: `AskingVerification` (nach "Nein"-Klick)
- Neue UI abhängig von gewählter Variante
- Neue Reaktionstexte und Bilder des Magiers für Case 1 und Case 2
