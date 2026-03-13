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

## Problem

Aus den reinen Spieldaten (3 Stapelwahlen + gefundene Karte) lassen sich diese beiden
Fälle **nicht direkt unterscheiden**, weil wir nie wissen, welche Karte der User
tatsächlich im Kopf hatte.

## Analysierte Lösungsansätze

### Ansatz 1: Fehlerszenario-Analyse (vielversprechendste Option)

Da der Algorithmus deterministisch ist, lässt sich für jede mögliche Falsch-Wahl
berechnen, welche Karte stattdessen gefunden worden wäre. Bei 3 Runden und je 2
alternativen Stapelwahlen ergeben sich bis zu 6 "Fehlerkandidaten".

Nach einem "Nein" fragen wir: *"Vélsche Karte hatten Sie im Sinn?"*
- Antwortet der User mit einer der 6 Fehlerkandidaten → **Case 1** (echter Fehler,
  nachvollziehbar)
- Antwortet der User mit einer anderen Karte oder gibt keine plausible Antwort →
  **Case 2** (Trolling / keine Karte gemerkt)

**Umsetzungsaufwand:** Mittel. Erfordert eine neue Funktion in `MagicTrick.elm` die
alle Fehlerkandidaten berechnet, plus UI für die Nachfrage.

**Nachteil:** Der User muss nach dem "Nein" aktiv eine Karte benennen, was den
Zaubercharakter leicht bricht.

### Ansatz 2: Timing-Daten bei Stapelwahl (ergänzender Hinweis)

Die Zeit zwischen Anzeige der Stapel und Klick wird gemessen. Sehr schnelle Klicks
(<500ms) deuten auf Unachtsamkeit oder Trolling hin; längere Überlegezeiten (2–3s)
sprechen für echtes Mitspielen.

**Umsetzungsaufwand:** Gering. `Time.now` bereits im Model vorhanden.

**Nachteil:** Kein zuverlässiges Signal allein — nur als zusätzliche Heuristik nutzbar.

### Ansatz 3: Sitzungshistorie

Wer in mehreren Spielhintereinander "Nein" klickt, ist mit hoher Wahrscheinlichkeit
ein Troll. Erfordert jedoch Persistenz (localStorage oder Backend) — aktuell nicht
im Scope.

## Empfehlung (noch offen)

**Ansatz 1 + 2 kombinieren:** Fehlerszenario-Analyse als Hauptmechanismus,
Timing-Daten als optionaler Verstärker. Muss aber hieb- und stichfest sein bevor
es implementiert wird — insbesondere die UX der Nachfrage nach der gemeinten Karte.

## Konsequenzen (wenn umgesetzt)

- Neue Funktion `errorCandidates : List UserSelection -> ProperSizedDeck -> List Card`
  in `MagicTrick.elm`
- Neuer AppPhase-Zustand: `AskingVerification` (nach "Nein"-Klick)
- Neue UI: Karten-Auswahl oder Texteingabe für die gemerkete Karte
- Neue Antwort-Texte mit französischem Akzent für beide Fälle
