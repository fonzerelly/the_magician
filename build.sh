#!/bin/bash
set -e

echo "Building..."

rm -rf dist
mkdir -p dist

ELM_HOME=$(pwd)/elm-home ./bin/elm make src/Main.elm --output=dist/Elm.js

mkdir -p dist/src
cp -r src/card-deck dist/src/card-deck
cp src/Background.png dist/src/Background.png

cat > dist/index.html <<'EOF'
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>The Magician</title>
  <style>body { margin: 0; }</style>
</head>
<body>
  <script src="Elm.js"></script>
  <script>Elm.Main.init();</script>
</body>
</html>
EOF

echo "Done. Output in dist/"
