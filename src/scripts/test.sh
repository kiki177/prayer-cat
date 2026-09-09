#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/prepare-vendor.sh
CMAKE_BIN="${CMAKE_BIN:-cmake}"
"$CMAKE_BIN" -S . -B build/tests -DCMAKE_BUILD_TYPE=Release -DSC_BUILD_TESTS=ON
"$CMAKE_BIN" --build build/tests --target CoreTests EngineTests UIRenderTests --parallel 4
build/tests/CoreTests tests
if [ -n "${SC_BUNDLED_MODEL_PATH:-}" ]; then build/tests/EngineTests "$SC_BUNDLED_MODEL_PATH"; fi
mkdir -p build/ui-renders
build/tests/UIRenderTests "$PWD/build/ui-renders"
