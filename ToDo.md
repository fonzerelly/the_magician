# ToDo – The Magician

## Status (2026-03-11)

Build-Setup self-contained, 74 Tests grün:
- `./run-tests.sh` — funktioniert
- `./build.sh` — erstellt produktionsreifen Build in `dist/` (Assets unter `dist/src/`)
- `./start-app.sh` — startet `elm reactor` (statische Assets nur über `dist/` nutzbar)

---

## Offene Punkte

### [OFFEN] "War das Ihre Karte?" einbauen
Nach dem Aufdecken der Karte soll der Magier fragen ob es die richtige Karte war.
Zwei Antwort-Buttons: Ja / Nein. Führt zu unterschiedlichen Magier-Animationen.

### [OFFEN] Animation: Magier-Ärger bei "Nein"
Neue Magier-Animation/Bild für den Fall dass der User "Nein" klickt.
Magier reagiert empört oder theatralisch beleidigt — einheitlich, ohne Troll-Erkennung.

### [OFFEN] Animation: Magier-Freude bei "Ja"
Neue Magier-Animation/Bild für den Fall dass der User "Ja" klickt.
Magier reagiert triumphierend oder selbstgefällig.

### [OFFEN] Audio ausbauen
Bestehende Audio-Aufbereitung erweitern: Soundeffekte oder Musik für die neuen
Spielphasen (Kartenaufdeckung, Ja/Nein-Reaktion, Neustart).

### [OFFEN] Sprechblase besser designen und neuen Text einfügen
Die Instruktions-Sprechblase am oberen Rand braucht ein besseres visuelles Design
und neue/überarbeitete Texte für die einzelnen Phasen des Tricks.

### [OFFEN] Nächste Runde implementieren
Nach dem Austeilen aller 21 Karten soll der Nutzer eine Runde wählen (welcher Stapel
enthält seine Karte), danach werden die Stapel neu zusammengelegt und erneut ausgeteilt —
insgesamt 3 Runden. Danach zeigt der Magier die gemerkete Karte.
