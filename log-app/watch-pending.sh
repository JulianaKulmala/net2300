#!/bin/bash

################################################################################
# Watch Pending Logs
# 
# This script runs read-pending.sh in a loop every second
# Press Ctrl+C to stop
#
# Usage: ./watch-pending.sh
################################################################################

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to read-pending.sh
READ_PENDING_SCRIPT="$SCRIPT_DIR/read-pending.sh"

# Check if read-pending.sh exists
if [ ! -f "$READ_PENDING_SCRIPT" ]; then
    echo "Error: read-pending.sh not found at $READ_PENDING_SCRIPT"
    exit 1
fi

# Check if read-pending.sh is executable
if [ ! -x "$READ_PENDING_SCRIPT" ]; then
    echo "Error: read-pending.sh is not executable"
    echo "Run: chmod +x $READ_PENDING_SCRIPT"
    exit 1
fi

echo "Watching pending logs (refreshing every second)..."
echo "Press Ctrl+C to stop"
echo "========================================"
echo ""

# Run in a loop
while true; do
    # Clear screen for cleaner output
    clear
    
    # Display timestamp
    echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    
    # Run the read-pending script
    "$READ_PENDING_SCRIPT"
    
    # Wait 1 second before next iteration
    sleep 1
done
