#!/usr/bin/env bash
# The one command that builds a Leenium ISO.
set -euo pipefail
cd "$(dirname "$0")/.."

step() { echo; echo "━━━ $* ━━━"; }
die()  { echo "❌ $*" >&2; exit 1; }

step "ISO profile"
./scripts/sync-payload.sh

step "Preflight"
W=build/profile/airootfs/etc/systemd/system/multi-user.target.wants
grep -qx git build/profile/packages.x86_64 || die "package 'git' is missing: the live system cannot clone Leenium"
[[ -L "$W/leenium-payload.service" ]]     || die "leenium-payload.service is not enabled"
[[ -L "$W/leenium-live-user.service" ]]   || die "leenium-live-user.service is not enabled"
echo "✅ preflight passed"

step "mkarchiso"
sudo rm -rf build/work
sudo rm -f out/leenium-*.iso out/leenium-*.iso.sha256
sudo mkarchiso -v -w build/work -o out build/profile

iso="$(ls -t out/leenium-*.iso | head -1)"
( cd out && sha256sum "$(basename "$iso")" > "$(basename "$iso").sha256" )

step "Result"
printf '%s  %d MiB\n' "$iso" $(( $(stat -c %s "$iso") / 1024 / 1024 ))
echo "✅ done"
