# ToDo – The Magician

## Status (2026-03-10)

Build-Setup wurde auf self-contained umgestellt:
- `./run-tests.sh` — funktioniert, 57 Tests grün
- `./start-app.sh` — startet `elm reactor`, aber Assets werden nicht ausgeliefert (siehe unten)
- `./build.sh` — erstellt produktionsreifen Build in `dist/` (funktioniert)

---

### [OFFEN] elm reactor liefert keine statischen Assets

`elm reactor` kann keine SVGs und PNGs ausliefern — alle Karten und das Hintergrundbild bekommen 404:

```
GET /src/card-deck/back.svg   → 404
GET /src/Background.png       → 404
```

Die App startet zwar, aber ohne Bilder. Für die Entwicklungsumgebung brauchen wir einen anderen Ansatz — entweder einen statischen Fileserver (z.B. `python3 -m http.server` aus `dist/` nach einem `elm make`) oder ein anderes Tool.

---

## Offene Punkte

### [OFFEN] Kartenanimation überarbeiten
Die Flip-Animation beim Austeilen der Karten entspricht noch nicht der Vorstellung:

**Gewünschtes Verhalten:**
- Der Ziehstapel zeigt `back.svg` oberhalb der mittleren Karte (bereits umgesetzt)
- Wenn eine Karte gezogen wird: Eine zweite `back.svg` erscheint auf dem Stapel
- Diese zweite Instanz wird von links nach rechts schmäler (linker Rand fest, rechter Rand zieht sich ein), bis sie nur noch eine Linie ist
- An dieser Stelle: Austausch zu der aufgedeckten Karte (ebenfalls als Linie)
- Die aufgedeckte Karte verbreitert sich wieder von links nach rechts (linker Rand fest) bis zur vollen Breite
- Danach wandert die Karte in voller Breite zu ihrem Zielpfahl (Sliding-Animation fehlt noch komplett)

**Was noch fehlt / falsch ist:**
- Die Sliding-Phase zeigt die Karte aktuell NICHT fliegend zum Zielpfahl — sie erscheint nur sofort auf dem Stapel
- Die Flip-Richtung (von links nach rechts) muss visuell bestätigt werden
