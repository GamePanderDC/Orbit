#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== 1. Building WireGuardTURN.xcframework ==="
cd "$ROOT_DIR/WireGuardBridge"
make xcframework

echo "=== 2. Building Orbit iOS Archive (Unsigned) ==="
cd "$ROOT_DIR"
mkdir -p dist
xcodebuild archive \
  -project VKTurnProxy/VKTurnProxy.xcodeproj \
  -scheme VKTurnProxy \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath dist/Orbit.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO

echo "=== 3. Packaging Orbit-Feather.ipa ==="
rm -rf dist/Payload dist/Orbit-Feather.ipa
mkdir -p dist/Payload
cp -R dist/Orbit.xcarchive/Products/Applications/VKTurnProxy.app dist/Payload/

# Remove widget extension for Feather/AltStore compatibility (see docs/sideload.md)
if [ -d "dist/Payload/VKTurnProxy.app/PlugIns/OrbitWidgetExtension.appex" ]; then
  echo "Removing OrbitWidgetExtension for Feather compatibility..."
  rm -rf "dist/Payload/VKTurnProxy.app/PlugIns/OrbitWidgetExtension.appex"
fi

cd dist
zip -r -9 Orbit-Feather.ipa Payload
echo "=== Done! IPA created at dist/Orbit-Feather.ipa ==="
ls -lh Orbit-Feather.ipa
