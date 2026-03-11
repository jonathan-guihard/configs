#!/usr/bin/env bash
# Hook script: writes Claude Code permission mode to a temp file
# Receives JSON via stdin from Claude Code hooks
set -euo pipefail
json=$(cat)
session_id=$(echo "$json" | jq -r '.session_id // empty')
mode=$(echo "$json" | jq -r '.permission_mode // empty')
if [[ -n "$session_id" && -n "$mode" ]]; then
  echo "$mode" > "/tmp/claude-mode-${session_id}"
fi
