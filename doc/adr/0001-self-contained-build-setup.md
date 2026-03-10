# ADR 0001: Self-contained Build Setup ohne Node.js

**Datum:** 2026-03-10
**Status:** Akzeptiert

## Kontext

Das Projekt wurde ursprünglich mit `create-elm-app` aufgesetzt, einem Tool das Node.js und npm voraussetzt. Beim Versuch die App nach längerer Pause neu zu starten traten zwei Probleme auf:

1. **`elm-app` inkompatibel mit aktuellen Node-Versionen** — das `primordials`-Fehler ist ein bekanntes Problem wenn alte npm-Pakete (die für Node < 12 geschrieben wurden) auf neueren Node-Versionen laufen.
2. **`elm-test` findet kein `elm`-Binary** — weil `elm` nicht global installiert war und je nach aktiver Node-Version im PATH fehlte.

Der eigentliche Auslöser der Entscheidung: **Elm wird seit 2019 nicht mehr aktiv weiterentwickelt** (letzte Version 0.19.1). Das bedeutet, dass der offizielle Elm-Paketserver `package.elm-lang.org` irgendwann abgeschaltet werden kann. In diesem Fall wäre das Projekt nicht mehr buildbar, da `elm` beim Kompilieren Pakete vom Server nachlädt.

Dasselbe gilt für den npm-Ökosystem-Ansatz: `create-elm-app` und seine Dependencies sind ebenfalls nicht mehr gepflegt.

## Entscheidung

Wir haben uns für ein vollständig self-contained Build-Setup entschieden:

- **`bin/elm`** — das offizielle Elm 0.19.1 Linux-Binary, direkt ins Repository committed
- **`bin/elm-test-rs/`** — `elm-test-rs` v3.0.1 als Rust-Binary, ebenfalls committed
- **`elm-home/`** — alle Elm-Paketabhängigkeiten lokal im Projekt gespeichert; die Skripte setzen `ELM_HOME=$(pwd)/elm-home` damit der Compiler nicht ins globale `~/.elm` greift
- **`start-app.sh`** — startet `elm reactor` direkt über `./bin/elm`, kein Node nötig
- **`run-tests.sh`** — führt `elm-test-rs` mit lokalem Compiler aus

Assets (Karten-SVGs, Hintergrundbild) wurden von `public/` nach `src/` verschoben, damit `elm reactor` sie über seinen eingebauten Dateiserver ausliefern kann.

## Alternativen die verworfen wurden

- **Node-Version pinnen via `.nvmrc`**: Löst das Problem nicht grundsätzlich — npm-Pakete können trotzdem verschwinden, und jeder Entwickler braucht nvm.
- **Python-basierter Static Server** (`python3 -m http.server`): Python ist zwar meistens verfügbar, aber eine weitere externe Abhängigkeit. `elm reactor` erfüllt denselben Zweck ohne Extra-Tool.
- **Nur `elm make` ohne Dev-Server**: Würde Hot-Reload-Komfort wegnehmen ohne echten Vorteil.

## Konsequenzen

**Positiv:**
- Das Projekt ist nach einem `git clone` sofort buildbar — kein `npm install`, kein Internet, keine Vorbedingungen außer einem Linux-System.
- Kein Abhängigkeitsverfall: Alle Tools und Pakete sind eingefroren und versioniert.
- Einfaches Setup das man auch ohne Claude-Hilfe starten kann.

**Negativ:**
- Das Repository ist größer als üblich (~28 MB elm-Binary, ~8 MB elm-test-rs, Paketquellen).
- Binaries sind Linux-spezifisch — auf macOS oder Windows müssten andere Binaries hinterlegt werden.
- Kein Hot-Reload: `elm reactor` kompiliert bei jedem Seitenaufruf neu, zeigt aber keine Live-Updates beim Speichern.
