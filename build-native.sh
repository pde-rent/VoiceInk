#!/bin/bash
# VoiceInk Native ARM64 Build Script
# Run this on your M4 Mac: ./build-native.sh
# Builds VoiceInk for native ARM64 - NO Rosetta required

set -e

echo "======================================"
echo "  VoiceInk Native ARM64 Build"
echo "======================================"
echo ""

# Verify we're on ARM64
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
    echo "⚠️  WARNING: Not running on ARM64 architecture"
    echo "This script is optimized for Apple Silicon (M1/M2/M3/M4)"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✓ Architecture: Native ARM64 ($ARCH)"
echo ""

# Check for xcodebuild
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found"
    echo "   Install Xcode from the Mac App Store"
    echo "   After installing, run: sudo xcode-select -s /Applications/Xcode.app"
    exit 1
fi

echo "✓ Xcode found"
echo ""
echo "Building VoiceInk..."
echo "  - Target: macOS (native ARM64)"
echo "  - Default Model: Parakeet V3"
echo "  - No Rosetta: 100% native"
echo ""

# Build for native ARM64 only - no Rosetta, no universal binaries
xcodebuild \
    -project VoiceInk.xcodeproj \
    -scheme VoiceInk \
    -configuration Debug \
    -destination 'platform=macOS,arch=arm64' \
    -arch arm64 \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    clean build 2>&1 | grep -E "error:|warning:|BUILD SUCCEEDED|BUILD FAILED" || true

BUILD_RESULT=${PIPESTATUS[0]}

echo ""
if [ $BUILD_RESULT -eq 0 ]; then
    echo "✅ BUILD SUCCESSFUL!"
    echo ""
    echo "To launch VoiceInk:"
    echo "  ./VoiceInk.app/Contents/MacOS/VoiceInk"
    echo ""
    echo "Or drag the app to your Applications folder"
    echo ""
    echo "📌 Default: Parakeet V3 (multilingual)"
    echo "📌 Download models in app: Settings → AI Models"
else
    echo "❌ BUILD FAILED"
    echo "   Check the error messages above"
    exit 1
fi
