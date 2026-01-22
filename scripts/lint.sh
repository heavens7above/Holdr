#!/bin/bash
# lint.sh
# Runs SwiftLint if available

if command -v swiftlint &> /dev/null; then
    echo "🔍 Running SwiftLint..."
    swiftlint
else
    echo "⚠️ SwiftLint not correctly installed, skipping linting."
fi
