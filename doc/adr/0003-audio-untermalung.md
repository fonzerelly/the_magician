# ADR 0003: Audio-Untermalung

**Datum:** 2026-03-15
**Status:** Draft – noch nicht entschieden

## Kontext

Das Spiel hat bisher nur visuelle Rückmeldung. Eine Audio-Ebene könnte die
Immersion erhöhen und dem Magier-Charakter mehr Persönlichkeit verleihen.
Drei konkrete Ideen stehen zur Diskussion:

1. **Hintergrundmelodie** — eine atmosphärische Schleife die dauerhaft läuft
2. **Magier-Soundeffekte** — kurze Sounds die zu bestimmten Magier-Darstellungen passen
3. **Karten-Schnipp-Sound** — ein taktiles Geräusch beim Austeilen jeder Karte

## Technische Grundlagen: Audio in Elm

Elm hat keine native Audio-API. Es gibt zwei Wege:

### Weg 1: HTML-Audio-Element (einfach)

```elm
Html.audio
    [ Html.Attributes.src "/sounds/background.mp3"
    , Html.Attributes.autoplay True
    , Html.Attributes.loop True
    ]
    []
```

Funktioniert für Hintergrundmusik die einfach läuft. Keine JS-Ports nötig.
Einschränkung: Kein programmatischer Start/Stopp aus Elm-Logik heraus.
Browser-Autoplay-Policies können das stummschalten bis der User interagiert hat —
beim Spiel kein Problem, weil der User zuerst klickt bevor Musik starten würde.

### Weg 2: JavaScript-Ports (flexibel)

Elm sendet eine Nachricht über einen Port, JavaScript spielt den Sound ab:

```elm
-- Elm-Seite
port playSound : String -> Cmd msg

-- Aufruf z.B. beim Austeilen:
playSound "card-snap"
```

```js
// JS-Seite (index.js)
app.ports.playSound.subscribe(function(name) {
    new Audio(`/sounds/${name}.mp3`).play();
});
```

Vorteil: volle Kontrolle — Sound kann zu jedem Elm-Event ausgelöst werden.
Nachteil: Ein kleines JS-Stück nötig, und jede neue Sound-Aktion braucht
einen eigenen Port oder eine generische Port-Nachricht.

## Die drei Ideen im Einzelnen

### Idee 1: Hintergrundmelodie

**Beschreibung:** Eine kurze Melodie (~1–2 Minuten) die in einer Schleife
läuft solange das Spiel offen ist. Stil: mysteriös, leicht theatralisch —
passend zum Zauberer-Charakter.

**Implementierungsaufwand:** Sehr gering.
Ein einziges `Html.audio`-Element mit `loop=True` im View. Kein Port nötig.
Schätzung: **< 1 Stunde** technische Umsetzung.

**Soundquelle:**
Freie Quellen mit lizenzfreier Musik:

- [Pixabay Audio](https://pixabay.com/music/) — große Auswahl, direkt downloadbar, CC0
- [Mixkit](https://mixkit.co/free-stock-music/) — kuratiert, hochwertig, kostenlos
- [OpenGameArt](https://opengameart.org) — oft MIDI-basiert, viele Fantasy/Mystik-Themen
- KI-Generierung: [Suno](https://suno.com) oder [Udio](https://www.udio.com) —
  man beschreibt den gewünschten Stil ("mysterious magic, French cabaret, looping")
  und bekommt in Minuten einen passenden Track

**Schleife:** Trivial — HTML5 `loop`-Attribut, kein zusätzlicher Code.

**Risiko:** Dauerhaft laufende Musik kann nerven. Empfehlung: Lautstärke-Toggle
oder Mute-Button (ein zusätzliches Bool im Model + ein Klick-Handler).
Aufwand dafür: ~30 Minuten.

---

### Idee 2: Magier-Soundeffekte pro Darstellung

**Beschreibung:** Kurze Sounds (1–3 Sekunden) die beim Wechsel zu einer
bestimmten Magier-Emotion abgespielt werden. Beispiele:

| Magier-Zustand | Sound-Idee |
| --- | --- |
| Triumphierend (richtige Karte) | Fanfare, Trommelwirbel |
| Empört ("Sie schummeln!") | dramatisches Stöhnen, Knall |
| Verständnisvoll | sanftes "Hmm", weiche Glocke |
| Verwirrt | kurzes Fragezeichen-Jingle |
| Intro / Beschwörung | mystisches Rauschen, Gong |

**Implementierungsaufwand:** Mittel.
Benötigt JS-Ports (Weg 2). Der Port selbst ist schnell geschrieben.
Die Herausforderung ist die Zustandslogik: wann genau soll der Sound
ausgelöst werden, damit er nicht mehrfach abspielt wenn der View neu
gerendert wird? Lösung: Sound nur beim **Übergang** in einen neuen Zustand
auslösen, nicht bei jedem render — also im `update` statt im `view`.

Schätzung: **2–4 Stunden** (Port + Zustandslogik + Testen)

**Soundquelle:**
- [Freesound.org](https://freesound.org) — riesige CC-lizenzierte Bibliothek,
  suchbar nach Stichwort (z.B. "fanfare", "magic whoosh", "dramatic sting")
- KI-Generierung: [ElevenLabs Sound Effects](https://elevenlabs.io/sound-effects)
  — man beschreibt den Sound in natürlicher Sprache und bekommt ihn sofort
- Vorteil KI: man kann exakt den passenden Sound beschreiben statt aus
  tausenden Samples zu suchen

**Anzahl benötigter Sounds:** ~5–8 verschiedene, je nach Anzahl der
unterschiedlichen Magier-Zustände. Gut handhabbar.

---

### Idee 3: Vertonung der Magier-Texte (eigene Stimme)

**Beschreibung:** Die Texte die der Magier im Spiel spricht — Ansagen zwischen
den Runden, die Enthüllung, die Reaktion auf "Nein" — werden vom Spielentwickler
selbst eingesprochen und als Audio-Dateien hinterlegt. Statt die Texte nur zu
lesen, *hört* der User den Magier sprechen.

Das ist eine der wirkungsvollsten Audio-Maßnahmen überhaupt: eine echte Stimme
gibt dem Charakter sofort Persönlichkeit die kein Text und kein Bild allein
erreichen kann.

**Implementierungsaufwand:** Gering.
Technisch identisch zu Idee 2 (Magier-Soundeffekte via Port). Der einzige
Unterschied: die Audio-Dateien enthalten Sprache statt Musik/Geräusche.
Zustandslogik ist dieselbe — Sprachausgabe beim Übergang in einen neuen
App-Zustand auslösen, nicht bei jedem render.

Schätzung: **1–2 Stunden** technische Umsetzung (wenn Port aus Idee 2 schon
existiert: **< 30 Minuten**)

**Aufnahme der Sprachsamples:**

Was man braucht: ein Mikrofon (Headset oder Handymikrofon reicht), eine ruhige
Umgebung, und eine freie Software zum Schneiden. Empfehlung:

- **Audacity** (kostenlos, Windows/Mac/Linux) — aufnehmen, Stille abschneiden,
  als `.mp3` exportieren; pro Satz ~5 Minuten Arbeit
- Alternativ direkt im Browser: [voice-recorder.com](https://voice-recorder-online.com)

**Anzahl der Sprachsamples:** hängt von der Anzahl der Magier-Texte ab.
Aktuell im Spiel sind es ca. 8–12 verschiedene Texte (Intro, Runden-Ansagen,
Enthüllung, Reaktionen). Aufnahme aller Samples in einem Sitz: ~30–45 Minuten.

**Besondere Stärke dieser Idee:**
- Keine Lizenzfragen — die eigene Stimme ist immer frei
- Der französische Akzent / Charakter des Magiers (bereits in den Texten angelegt)
  kann in der Stimme weitergeführt werden
- Nachvertonung einzelner Texte bei Änderungen ist trivial — einfach neu aufnehmen

**Kombination mit Magier-Bildern (aus ADR 0002):**
Sprachausgabe + passendes Bild + passender Soundeffekt (Idee 2) gleichzeitig
ausgelöst ergibt die stärkste Wirkung. Alle drei teilen denselben technischen
Auslöser (Port-Nachricht beim Zustandsübergang), laufen aber unabhängig.

**Schleife:** Nicht sinnvoll — jeder Satz wird einmal abgespielt, kein Loop.

---

### Idee 4: Karten-Schnipp-Sound

**Beschreibung:** Beim Austeilen jeder Karte (derzeit ~210 mal pro Spiel
bei 21 Karten × 3 Runden... nein, 21 Karten × 3 Runden = 63 Deals) wird ein
kurzes Klack-/Schnipp-Geräusch abgespielt das dem echten Kartenablegen entspricht.

Korrektur: Es sind 21 Karten pro Runde × 3 Runden = 63 Karten-Events insgesamt.
Bei ~100ms pro Karte (aktuelle Animation) bedeutet das den Sound alle 100ms.

**Implementierungsaufwand:** Gering bis mittel.
Port + eine Zeile im `update` beim `Tick`-Event wenn eine Karte ausgelegt wird.

Schätzung: **1–2 Stunden**

**Wichtige technische Einschränkung — Audio-Instanzen:**
Bei sehr schneller Wiederholung (alle 100ms) muss jedes `new Audio(...).play()`
eine **neue Instanz** erzeugen, nicht dieselbe wiederverwenden. Sonst wird der
Sound abgebrochen bevor er fertig ist. Das obige JS-Snippet macht das bereits
richtig (`new Audio(...)` erzeugt jedes Mal eine frische Instanz).

Bei ~100ms Intervall und einem ~300ms langen Snap-Sound würden 2–3 Sounds
gleichzeitig laufen — das klingt realistisch wie echtes Kartenmischen.

**Soundquelle:**
- Freesound.org: Suchbegriff "card flip", "card deal", "card snap" liefert
  sofort viele brauchbare Ergebnisse, meist CC0 oder CC-BY
- ElevenLabs: "a single playing card being placed on a wooden table"

**Schleife:** Nicht nötig — der Sound wird event-getriggert, nicht geloopt.

---

## Gesamtaufwand-Übersicht

| Idee | Technischer Aufwand | Sound beschaffen | Gesamt |
| --- | --- | --- | --- |
| Hintergrundmelodie | < 1h | 15 min (Pixabay/Suno) | **~1h** |
| Magier-Soundeffekte | 2–4h | 30 min (ElevenLabs) | **~3–5h** |
| Magier-Texte eingesprochen | < 30 min (wenn Port existiert) | 45 min (selbst aufnehmen) | **~1–1.5h** |
| Karten-Schnipp | 1–2h | 15 min (Freesound) | **~1.5–2.5h** |
| **Alle vier zusammen** | **~4–7h** | **~1.5h** | **~5.5–8.5h** |

---

## Mehrwert-Vergleich: Audio (ADR 0003) vs. Intention-Erkennung (ADR 0002)

| Kriterium | ADR 0002 (Intention) | ADR 0003 (Audio) |
| --- | --- | --- |
| Erster Eindruck | keiner | stark — sofort spürbar |
| Tiefe / Replayability | hoch — mehrere Ausgänge | mittel — Variation durch Sounds |
| Implementierungsaufwand | hoch (6-Feld: ~1–2 Tage) | niedrig–mittel (alle 3: ~4–7h) |
| Abhängigkeiten | viele neue Elm-Typen, neues UI | ein Port + Audio-Dateien |
| Risiko | Logikfehler schwer zu testen | Browser-Autoplay, Dateiformat |
| Zielgruppe-Wirkung | Spieler die mehrfach spielen | alle Spieler beim ersten Mal |
| Rückgängig machbar | nein (tiefe Architektur) | ja (Audio ist optional/addierbar) |

**Fazit:** Die Ideen sind **komplementär, nicht konkurrierend**.

Audio wirkt sofort beim ersten Spielstart — es ist der "Wow"-Faktor der die
Atmosphäre setzt. ADR 0002 wirkt erst wenn jemand "Nein" klickt — es ist der
"Aha"-Faktor der das Spiel interessant macht wenn man es mehrfach spielt.

Wenn die Zeit begrenzt ist, empfiehlt sich diese Reihenfolge:

1. **Hintergrundmelodie** (~1h) — größter atmosphärischer Gewinn pro Zeiteinheit
2. **Karten-Schnipp** (~2h) — macht die Animationsphase lebendig
3. **Magier-Texte eingesprochen** (~1–1.5h) — stärkster Charakter-Effekt, günstigste Ratio
4. **ADR 0002** (Intention-Erkennung) — tiefes Feature für Wiederspielwert
5. **Magier-Soundeffekte** (~3–5h) — schönes Finish, setzt Reaktions-Bilder voraus

## Empfehlung

**Hintergrundmelodie und Karten-Schnipp-Sound jetzt umsetzen** — zusammen
ca. 3 Stunden Aufwand, kein neuer Architektur-Aufwand, sofort sichtbarer Effekt.

Die **eingesprochenen Magier-Texte** sind von allen Ideen das beste
Aufwand-Wirkung-Verhältnis: ~1 Stunde Aufwand, keine Lizenzfragen, und eine
echte Stimme gibt dem Charakter sofort mehr Persönlichkeit als jedes Bild allein.

Magier-Soundeffekte sind erst sinnvoll wenn die Reaktionsbilder (aus ADR 0002)
existieren, weil Sound und Bild zusammen eine Emotion tragen — einzeln wirken
sie halbgar.

## Konsequenzen (wenn umgesetzt)

- Neue Verzeichnisstruktur: `public/sounds/` für Audio-Dateien
- Für Hintergrundmusik: ein `Html.audio`-Element im View, optional `Bool`
  im Model für Mute-Toggle
- Für Schnipp und Magier-Sounds: ein generischer Port
  `port playSound : String -> Cmd msg` + 5–10 Zeilen JS in `index.js`
- Dateiformate: `.mp3` als Hauptformat (universell), `.ogg` als Fallback
  für ältere Browser falls nötig
