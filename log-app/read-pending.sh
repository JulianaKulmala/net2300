#!/bin/bash

################################################################################
# Read Pending Logs from MariaDB Database
# 
# This script reads all log entries with status='pending' from the logs table
# and displays them ordered by id DESC
#
# Usage: ./read-pending.sh
################################################################################

# Database configuration
DB_HOST="localhost"
DB_PORT="3306"
DB_USER="root"
DB_PASS="rootpassword"
DB_NAME="logdb"

# Colors for outputy
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Check if mysql client is installed
################################################################################
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}Error: mysql client is not installed${NC}"
    echo "Install it with: brew install mysql (macOS) or sudo dnf install mysql (Rocky Linux)"
    exit 1
fi

################################################################################
# Display pending logs
################################################################################

# Display pending logs - only data fields
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -N -B \
    -e "SELECT id, message, status FROM logs WHERE status = 'pending' ORDER BY id ASC"

exit 0
