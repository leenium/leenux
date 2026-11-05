#!/usr/bin/env bash
# Render the PNGs Leenium needs from text (logo.svg). Run it once, then commit the PNGs.
set -euo pipefail
cd "$(dirname "$0")/.."

ACCENT="#33b8a8"
SVG=leenium/default/artwork/logo.svg
mkdir -p leenium/default/artwork

logo() {  # logo <size> <color> <output>
  sed "s/#FFFFFF/$2/g" "$SVG" | magick -background none -density 600 svg:- -resize "$1x$1" -strip "$3"
}

# Generic logo (os-release LOGO=leenium, fastfetch, …)
logo 256 "$ACCENT" leenium/default/artwork/leenium.png

echo "✅ artwork:"
ls -l leenium/default/artwork/*.png
