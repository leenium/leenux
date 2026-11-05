#!/usr/bin/env bash
# Fail if code or UI mentions names that do not belong to Leenium.
set -euo pipefail
cd "$(dirname "$0")/.."
pattern='leenium|\byay\b'
hits="$(grep -RInE -i "$pattern" leenium archiso/airootfs installer scripts 2>/dev/null \
        | grep -v '^scripts/.*no-foreign-names' || true)"
if [[ -n "$hits" ]]; then
  echo "❌ foreign names found:"; echo "$hits"; exit 1
fi
echo "✅ no foreign names"

