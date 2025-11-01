# Git Hooks

This directory contains git hooks that can be installed to automate testing and code quality checks.

## Available Hooks

### pre-push
Runs all GUT tests before allowing a push to the remote repository. If any tests fail, the push is aborted.

## Installation

From the project root, run:

```bash
./install-hooks.sh
```

This will copy the hooks from the `hooks/` directory to `.git/hooks/` and make them executable.

## Manual Installation

If the install script doesn't work, you can manually install hooks:

```bash
cp hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

## How It Works

When you run `git push`, the pre-push hook will:
1. Run all GUT tests in headless mode
2. If tests pass (exit code 0), the push proceeds
3. If tests fail (non-zero exit code), the push is aborted

## Bypassing the Hook

If you need to push without running tests (not recommended), you can use:

```bash
git push --no-verify
```

## Note for macOS Users

The hook assumes Godot is installed at `/Applications/Godot.app/Contents/MacOS/Godot`. If your Godot installation is elsewhere, update the path in `hooks/pre-push`.
