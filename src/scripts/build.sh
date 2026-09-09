#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/prepare-vendor.sh
CMAKE_BIN="${CMAKE_BIN:-cmake}"
MODEL_PATH="${SC_BUNDLED_MODEL_PATH:-$PWD/build/models/Qwen3-0.6B-Q8_0.gguf}"
if [ ! -f "$MODEL_PATH" ]; then
  python3 scripts/download_model.py "$MODEL_PATH"
fi
for ARCH in arm64 x86_64; do
  "$CMAKE_BIN" -S . -B "build/$ARCH" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="$ARCH" -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 -DSC_BUNDLED_MODEL_PATH="$MODEL_PATH"
  "$CMAKE_BIN" --build "build/$ARCH" --parallel 4
done
STAGE=$(mktemp -d /private/tmp/salahcat-package.XXXXXX)
trap 'rm -rf "$STAGE"' EXIT
ditto --norsrc --noextattr build/arm64/SalahCat.app "$STAGE/礼拜喵.app"
lipo -create build/arm64/SalahCat.app/Contents/MacOS/SalahCat build/x86_64/SalahCat.app/Contents/MacOS/SalahCat -output "$STAGE/礼拜喵.app/Contents/MacOS/SalahCat"
xattr -cr "$STAGE/礼拜喵.app"
codesign --force --sign "${SC_SIGN_IDENTITY:--}" --entitlements AppStore.entitlements "$STAGE/礼拜喵.app"
codesign --verify --strict "$STAGE/礼拜喵.app"
mkdir -p build/release
ditto -c -k --keepParent --norsrc --noextattr "$STAGE/礼拜喵.app" build/release/礼拜喵-macOS-v2.5.0.zip
printf 'Created build/release/礼拜喵-macOS-v2.5.0.zip\n'
