#!/bin/bash
set -e

echo "Building..."

rm -rf dist
mkdir -p dist

ELM_HOME=$(pwd)/elm-home ./bin/elm make src/Main.elm --output=dist/Elm.js

mkdir -p dist/src
cp -r src/card-deck dist/src/card-deck
cp -r src/magnus-states dist/src/magnus-states

PRELOAD_TAGS=$(ls src/magnus-states/ | sed 's|.*|  <link rel="preload" as="image" href="src/magnus-states/&">|')

cat > dist/index.html <<EOF
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>The Magician</title>
  <style>body { margin: 0; }</style>
$PRELOAD_TAGS
</head>
<body>
  <script src="Elm.js"></script>
  <script>Elm.Main.init();</script>
  <!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-X1WTR40ZVW"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-X1WTR40ZVW');
</script>
</body>
</html>
EOF

echo "Done. Output in dist/"
