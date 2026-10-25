#!/usr/bin/env bash
# Runs the library's tests with the pinned compiler (see tools/setup.sh). Exits non-zero when a check fails.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
HAXE_STD_PATH=.haxe/std .haxe/haxe -cp . -cp test -main TestMain --interp
