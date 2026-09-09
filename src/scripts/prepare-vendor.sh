#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
REV=73a43d1f69345aee8bb186ef4b3172cef892f2e5
if [ -f vendor/llama.cpp/CMakeLists.txt ]; then
  exit 0
fi
mkdir -p vendor
if [ -e vendor/llama.cpp ]; then
  printf 'vendor/llama.cpp exists but is incomplete. Restore it before building.\n' >&2
  exit 1
fi
git clone --no-checkout https://github.com/ggml-org/llama.cpp.git vendor/llama.cpp
git -C vendor/llama.cpp checkout --detach "$REV"
test "$(git -C vendor/llama.cpp rev-parse HEAD)" = "$REV"
