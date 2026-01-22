#!/bin/bash
# setup_dev.sh
# Sets up the development environment

echo "🛠️ Setting up development environment for Holdr..."

# Check for Swift
if ! command -v swift &> /dev/null; then
    echo "❌ Swift is not installed. Please install Xcode or swift-tools."
    exit 1
fi
echo "✅ Swift detected."

# Check for xcrun (needed for asset catalog compilation)
if ! command -v xcrun &> /dev/null; then
    echo "❌ xcrun is not installed. Please install Xcode Command Line Tools."
    exit 1
fi
echo "✅ xcrun detected."

# Optional: Check for SwiftLint
if ! command -v swiftlint &> /dev/null; then
    echo "⚠️ SwiftLint not found. Install it for code style enforcement (brew install swiftlint)."
else
    echo "✅ SwiftLint detected."
fi

# Build modules
echo "📦 resolving package dependencies..."
swift package resolve

echo "✅ Development environment ready!"
