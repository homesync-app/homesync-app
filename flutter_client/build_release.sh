#!/bin/bash
# HomeSync - Build release AAB for Play Store
# Run from flutter_client directory

set -e

echo "HomeSync - Build Release AAB"
echo "============================="

# Verify key.properties exists
if [ ! -f "android/key.properties" ]; then
  echo "ERROR: android/key.properties not found."
  echo "Create it with:"
  echo "  storePassword=YOUR_PASSWORD"
  echo "  keyPassword=YOUR_PASSWORD"
  echo "  keyAlias=homesync-key"
  echo "  storeFile=/path/to/homesync-release.keystore"
  exit 1
fi

# Verify version is bumped
CURRENT_VERSION=$(grep 'version:' pubspec.yaml | head -1 | awk '{print $2}')
echo "Current version: $CURRENT_VERSION"
echo ""
read -p "Did you bump the versionCode? (y/n) " -n 1 -r
echo ""

flutter clean
flutter pub get
flutter build appbundle --release \
  --dart-define=APP_ENV=production

echo ""
echo "Build complete!"
echo "AAB location: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "Upload to: https://play.google.com/console"
