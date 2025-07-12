#!/bin/bash

set -e

echo "🧹 Cleaning Flutter project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "📱 Installing iOS pods..."
cd ios
pod install
cd ..

echo "⚙️ Building iOS release without code signing..."
flutter build ios --release --no-codesign

echo "📦 Creating IPA package..."
cd build/ios/iphoneos
mkdir -p Payload
cp -r Runner.app Payload/
zip -r Runner.ipa Payload
rm -rf Payload

echo "✅ IPA build completed: $(pwd)/Runner.ipa"

