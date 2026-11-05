#!/usr/bin/env bash
# Fail if any key chord is bound more than once in leenium/config/hypr/modules/bindings.
set -euo pipefail
cd "$(dirname "$0")/.."
B=leenium/config/hypr/modules/bindings

# Every binding call starts with the chord string. The four helpers live in
# hyprland.lua; hl.bind and media() are also accepted for local modules.
chords="$(grep -RhoE '(bind_dsp|bind_exec|bind_script|bind_fn|bind_dispatch|hl\.bind|media)\("[^"]+"' "$B" \
          | sed -E 's/^[^"]*"//; s/"$//' \
          | tr '[:lower:]' '[:upper:]' | tr -d ' ')"

# Loops generate chords at runtime; expand the two loops we use.
# Workspaces: SUPER/SUPER+SHIFT/SUPER+SHIFT+ALT + 1..0
if grep -q 'local keys = {' "$B/workspaces.lua" 2>/dev/null; then
  chords="$(printf '%s\n' "$chords" \
    | grep -vE '^SUPER\+$|^SUPER\+SHIFT\+$|^SUPER\+SHIFT\+ALT\+$' || true)"
  for key in 1 2 3 4 5 6 7 8 9 0; do
    chords+=$'\n'"SUPER+$key"$'\n'"SUPER+SHIFT+$key"$'\n'"SUPER+SHIFT+ALT+$key"
  done
fi

# Groups: SUPER + ALT + 1..5
if grep -q 'SUPER + ALT + " \.\. index' "$B/groups.lua" 2>/dev/null; then
  chords="$(printf '%s\n' "$chords" | grep -vx 'SUPER+ALT+' || true)"
  for index in 1 2 3 4 5; do
    chords+=$'\n'"SUPER+ALT+$index"
  done
fi

dups="$(printf '%s\n' "$chords" | grep -v '^$' | sort | uniq -d)"
if [[ -n "$dups" ]]; then
  echo "❌ duplicate key bindings:"
  echo "$dups"
  exit 1
fi
echo "✅ no duplicate key bindings ($(printf '%s\n' "$chords" | grep -vc '^$') chords)"
