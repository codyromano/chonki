#!/bin/sh
# Installation script for git hooks

HOOKS_DIR=".git/hooks"
SOURCE_DIR="hooks"

echo "Installing git hooks..."

# Install pre-push hook
if [ -f "$SOURCE_DIR/pre-push" ]; then
    cp "$SOURCE_DIR/pre-push" "$HOOKS_DIR/pre-push"
    chmod +x "$HOOKS_DIR/pre-push"
    echo "✅ Installed pre-push hook"
else
    echo "❌ pre-push hook not found in $SOURCE_DIR"
fi

echo "Git hooks installation complete!"
