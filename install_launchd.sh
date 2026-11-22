#!/bin/bash
# Installs a macOS launchd job that runs the digest daily.
# Usage: ./install_launchd.sh [HOUR] [MINUTE]   (default 6 0, in the Mac's local time)
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LABEL="com.stockdigest.daily"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
HOUR="${1:-6}"
MINUTE="${2:-0}"
PYTHON="$PROJECT_DIR/.venv/bin/python"

[ -x "$PYTHON" ] || { echo "Create the virtualenv first (see README step 2)."; exit 1; }
[ -f "$PROJECT_DIR/.env" ] || { echo "Missing .env (copy .env.example and fill it in)."; exit 1; }

mkdir -p "$PROJECT_DIR/logs" "$HOME/Library/LaunchAgents"

cat > "$PLIST" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$PYTHON</string>
    <string>$PROJECT_DIR/stock_digest.py</string>
  </array>
  <key>WorkingDirectory</key><string>$PROJECT_DIR</string>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>$HOUR</integer>
    <key>Minute</key><integer>$MINUTE</integer>
  </dict>
  <key>StandardOutPath</key><string>$PROJECT_DIR/logs/digest.log</string>
  <key>StandardErrorPath</key><string>$PROJECT_DIR/logs/digest.err.log</string>
</dict>
</plist>
PLIST_EOF

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo "Installed: runs daily at $(printf '%02d:%02d' "$HOUR" "$MINUTE") local time."
echo "Test it now:   launchctl kickstart -k gui/$(id -u)/$LABEL"
echo "Logs:          $PROJECT_DIR/logs/"
echo "Uninstall:     launchctl bootout gui/$(id -u)/$LABEL && rm \"$PLIST\""
