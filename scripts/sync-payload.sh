#!/usr/bin/env bash
# Assemble the final ISO profile in build/profile:
#   archiso/ (committed)  +  the Leenium payload (committed)
set -euo pipefail
cd "$(dirname "$0")/.."
P=build/profile
AIR="$P/airootfs"

# ── 0. Only committed work goes into the ISO ───────────────────────────────
if [[ -n "$(git -C leenium status --porcelain)" ]]; then
  echo "❌ leenium/ has unsaved changes. Save them first:"
  echo "   git -C leenium add -A && git -C leenium commit -m \"<type>(<scope>): <what you did>\""
  exit 1
fi
branch="$(git -C leenium rev-parse --abbrev-ref HEAD)"
[[ "$branch" == master ]] || echo "⚠  leenium/ is on branch '$branch'"

# ── 1. A fresh copy of the committed profile ───────────────────────────────
mkdir -p build
rm -rf "$P"
cp -a archiso "$P"

# ── 2. The payload, as a git bundle (cloned at boot by leenium-payload.service)
mkdir -p "$AIR/usr/share"
git -C leenium bundle create "$PWD/$AIR/usr/share/leenium.bundle" --all

# ── 3. Starter files of the live user → /etc/skel ─────────────────────────
if [[ -d leenium/skel ]]; then
  mkdir -p "$AIR/etc/skel"
  cp -a leenium/skel/. "$AIR/etc/skel/"
fi

# ── 4. System defaults → /etc (dconf, portals, PATH, …) ───────────────────
if [[ -d leenium/default/etc ]]; then
  cp -a leenium/default/etc/. "$AIR/etc/"
fi

# ── more steps are added here in later chapters ───────────────────────────

echo "✅ build/profile ready ($(git -C leenium describe --tags --always))"
