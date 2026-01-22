#!/bin/bash
set -e

# Configuration
APP_NAME="Holdr"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
DMG_NAME="${BUILD_DIR}/${APP_NAME}.dmg"

echo "🚀 Starting build process for ${APP_NAME}..."

# 1. Clean
echo "Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 2. Build Release
echo "Building release binary..."
swift build -c release

# 3. Create Bundle Structure
echo "Creating App Bundle..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# 4. Copy Binary & Resources
echo "Copying executable and resources..."
cp ".build/release/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"

# 4b. Compiling Assets.xcassets
echo "Compiling Assets.xcassets..."
mkdir -p "${APP_BUNDLE}/Contents/Resources"
xcrun actool Sources/Holdr/Resources/Assets.xcassets --compile "${APP_BUNDLE}/Contents/Resources" --platform macosx --minimum-deployment-target 13.0 --app-icon AppIcon --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"


# Convert iconset to icns



# 5. Create Info.plist
echo "Generating Info.plist..."
cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 6. Sign
echo "Signing application..."
codesign --force --deep --sign - "${APP_BUNDLE}"

# 7. Create DMG
echo "Packaging into DMG..."
hdiutil create -volname "${APP_NAME}" -srcfolder "${APP_BUNDLE}" -ov -format UDZO "${DMG_NAME}"

echo "✅ Build complete!"
echo "Artifacts:"
echo "  - App: ${APP_BUNDLE}"
echo "  - DMG: ${DMG_NAME}"
