#!/bin/bash

# Set paths
LOG_FILE="/var/log/myapp.log"
ARCHIVE_DIR="/var/log/archive"
DATE=$(date +%Y-%m-%d)
ROTATED_LOG="${ARCHIVE_DIR}/myapp-${DATE}.log"

# Ensure archive directory exists
mkdir -p "$ARCHIVE_DIR"

# Rotate the log
if [ -f "$LOG_FILE" ]; then
  mv "$LOG_FILE" "$ROTATED_LOG"
  touch "$LOG_FILE"
  chmod 644 "$LOG_FILE"
fi
