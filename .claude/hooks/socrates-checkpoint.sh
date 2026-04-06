#!/bin/bash
# Silent checkpoint for Socratic tutor sessions.
# Runs as a Stop hook — captures the last teaching response
# so state survives Ctrl+C.

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$CWD" ] && exit 0

# Only during active sessions
[ ! -f "$CWD/.socrates-session-active" ] && exit 0

MESSAGE=$(echo "$INPUT" | jq -r '.last_assistant_message // empty' 2>/dev/null)
[ -z "$MESSAGE" ] && exit 0

LESSON=$(grep -oP '(?<=\*\*Lesson\*\*: ).*' "$CWD/student/index.md" 2>/dev/null || echo "unknown")
PHASE=$(grep -oP '(?<=\*\*Phase\*\*: ).*' "$CWD/student/index.md" 2>/dev/null || echo "unknown")
TIMESTAMP=$(date -Iseconds)

cat > "$CWD/.socrates-state" << EOF
lesson: $LESSON
phase: $PHASE
timestamp: $TIMESTAMP
last_response: |
$(echo "$MESSAGE" | sed 's/^/  /')
EOF

exit 0
