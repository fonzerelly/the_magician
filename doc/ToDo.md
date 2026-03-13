# ToDo – The Magician

## Status (2026-03-11)

Build-Setup self-contained, 74 Tests grün:
- `./run-tests.sh` — funktioniert
- `./build.sh` — erstellt produktionsreifen Build in `dist/` (Assets unter `dist/src/`)
- `./start-app.sh` — startet `elm reactor` (statische Assets nur über `dist/` nutzbar)

---

## Offene Punkte

### [OFFEN] "War das Ihre Karte?" – User-Intention erkennen
Nach der Kartenaufdeckung soll der User Ja/Nein antworten können. Bei "Nein" gibt
es zwei Fälle: echter Fehler beim Stapelklicken vs. absichtliches Testen/Trollen.
Analyse und Lösungsansätze in `doc/adr/0002-user-intention-detection-after-wrong-card.md`.
Vor Implementierung nochmal gemeinsam besprechen ob der gewählte Ansatz hieb- und
stichfest ist.

### [OFFEN] Sprechblase besser designen und neuen Text einfügen
Die Instruktions-Sprechblase am oberen Rand braucht ein besseres visuelles Design
und neue/überarbeitete Texte für die einzelnen Phasen des Tricks.

### [OFFEN] Nächste Runde implementieren
Nach dem Austeilen aller 21 Karten soll der Nutzer eine Runde wählen (welcher Stapel
enthält seine Karte), danach werden die Stapel neu zusammengelegt und erneut ausgeteilt —
insgesamt 3 Runden. Danach zeigt der Magier die gemerkete Karte.
