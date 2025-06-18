#!/bin/bash

# Build script for Apple TV Streaming App
# This script builds the app for testing on LambdaTest

set -e

echo "🚀 Building Apple TV Streaming App for Testing..."

# Configuration
PROJECT_NAME="StreamingApp"
SCHEME_NAME="StreamingApp"
CONFIGURATION="Release"
ARCHIVE_PATH="build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="build"
EXPORT_OPTIONS="StreamingApp/ExportOptions.plist"

# Create build directory
mkdir -p build

echo "📦 Creating archive..."
xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
           -scheme "${SCHEME_NAME}" \
           -destination 'generic/platform=tvOS' \
           -configuration "${CONFIGURATION}" \
           archive -archivePath "${ARCHIVE_PATH}"

echo "📱 Exporting IPA..."
xcodebuild -exportArchive \
           -archivePath "${ARCHIVE_PATH}" \
           -exportPath "${EXPORT_PATH}" \
           -exportOptionsPlist "${EXPORT_OPTIONS}"

echo "✅ Build completed successfully!"
echo "📁 IPA file location: ${EXPORT_PATH}/${PROJECT_NAME}.ipa"
echo ""
echo "🧪 Next steps for LambdaTest:"
echo "1. Upload the IPA file to LambdaTest.com"
echo "2. Select Apple TV device for testing"
echo "3. Follow the testing guide in LAMBDATEST_GUIDE.md"
echo ""
echo "📋 Files ready for testing:"
ls -la "${EXPORT_PATH}/"*.ipa 2>/dev/null || echo "No IPA files found - check build logs for errors"
