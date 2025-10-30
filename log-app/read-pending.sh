#!/bin/bash

################################################################################
# Read and Execute Pending Logs from MariaDB Database
# 
# This script reads all log entries with status='pending' from the logs table,
# executes the message field as a command, and updates status accordingly
#
# Usage: ./read-pending.sh
################################################################################

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYSQL_CONFIG="$SCRIPT_DIR/.mysql.cnf"

# Database configuration
DB_HOST="${DB_HOST:-}"
DB_PORT="3306"
DB_USER="root"
DB_PASS="rootpassword"
DB_NAME="logdb"

# Prompt for DB_HOST if not set
if [ -z "$DB_HOST" ]; then
    echo "Database Host Configuration"
    echo "----------------------------"
    read -p "Enter MariaDB host IP address (default: 127.0.0.1): " user_input
    DB_HOST="${user_input:-127.0.0.1}"
    echo "Using database host: $DB_HOST"
    echo ""
fi

################################################################################
# Create MySQL configuration file
################################################################################
create_mysql_config() {
    cat > "$MYSQL_CONFIG" << EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
database=$DB_NAME
EOF
    
    # Secure the configuration file
    chmod 600 "$MYSQL_CONFIG"
}

################################################################################
# Function to escape strings for safe SQL insertion
################################################################################
sql_escape() {
    local s="$1"
    # Escape backslashes first, then single quotes
    s="${s//\\/\\\\}"
    s="${s//\'/\'\'}"
    printf "%s" "$s"
}

################################################################################
# Ensure execution_log table exists
################################################################################
ensure_execution_log_table() {
    mysql --defaults-file="$MYSQL_CONFIG" -N -B \
        -e "CREATE TABLE IF NOT EXISTS execution_log (\n+                id INT AUTO_INCREMENT PRIMARY KEY,\n+                log_id INT NOT NULL,\n+                command TEXT NOT NULL,\n+                status ENUM('done','error') NOT NULL,\n+                exit_code INT NULL,\n+                output MEDIUMTEXT NULL,\n+                executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n+                INDEX idx_log_id (log_id),\n+                INDEX idx_status (status),\n+                INDEX idx_executed_at (executed_at)\n+            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;"
}

################################################################################
# Insert an execution record
################################################################################
log_execution() {
    local log_id="$1"
    local cmd="$2"
    local status="$3"
    local exit_code="$4"
    local out="$5"
    echo "Logging execution for log_id: $log_id, status: $status"
    echo "Command: $cmd"
    # Limit size to avoid overly large rows (optional)
    local cmd_limited
    local out_limited
    cmd_limited=$(printf '%.4000s' "$cmd")
    out_limited=$(printf '%.20000s' "$out")

    # Escape for SQL
    local cmd_esc
    local out_esc
    cmd_esc=$(sql_escape "$cmd_limited")
    out_esc=$(sql_escape "$out_limited")

    mysql --defaults-file="$MYSQL_CONFIG" -N -B <<SQL
INSERT INTO execution_log (log_id, command, exit_code, output)
VALUES ($log_id, '$cmd_esc',  ${exit_code:-NULL}, '$out_esc');
SQL
}

################################################################################
# Function to update log status
################################################################################
update_log_status() {
    local log_id=$1
    local new_status=$2
    
    mysql --defaults-file="$MYSQL_CONFIG" -N -B \
        -e "UPDATE logs SET status = '$new_status' WHERE id = $log_id"
}

################################################################################
# Function to process pending logs
################################################################################
process_pending_logs() {
    # Get pending logs ordered by id ASC
    mysql --defaults-file="$MYSQL_CONFIG" -N -B \
        -e "SELECT id, message, status FROM logs WHERE status = 'pending' ORDER BY id ASC" | \
    while IFS=$'\t' read -r id message status; do
        echo "Processing ID: $id"
        # Sanitize command: remove CR/LF characters, literal \n/\r, and trim
        cmd="$message"
        # Remove actual CR and LF characters entirely
        cmd="${cmd//$'\r'/}"
        cmd="${cmd//$'\n'/}"
        # Remove literal sequences \n and \r if present
        cmd="${cmd//\\n/}"
        cmd="${cmd//\\r/}"


        echo "Command: $cmd"
        echo "---"
        
        # Update status to 'processing'
        update_log_status "$id" "processing"
        
        # Execute the command and capture output
        output=$(eval "$cmd" 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            # Command succeeded - update status to 'done'
            update_log_status "$id" "done"
            log_execution "$id" "$cmd" "done" "$exit_code" "$output"
            echo "✓ Command completed successfully (ID: $id)"
            [ -n "$output" ] && echo "Output: $output"
        else
            # Command failed - update status to 'error'
            update_log_status "$id" "error"
            log_execution "$id" "$cmd" "error" "$exit_code" "$output"
            echo "✗ Command failed (ID: $id)"
            [ -n "$output" ] && echo "Error: $output"
        fi
        
        echo ""
    done
}

################################################################################
# Main execution
################################################################################

# Check if mysql client is installed
if ! command -v mysql &> /dev/null; then
    echo "Error: mysql client is not installed"
    echo "Install it with: brew install mysql (macOS) or sudo dnf install mysql (Rocky Linux)"
    exit 1
fi

# Create MySQL configuration file
create_mysql_config

# Ensure execution_log table exists
#ensure_execution_log_table

echo "Starting continuous pending log processor..."
echo "Press Ctrl+C to stop"
echo "========================================"
echo ""

# Cleanup function to remove config file on exit
cleanup() {
    echo ""
    echo "Cleaning up..."
    #rm -f "$MYSQL_CONFIG"
    exit 0
}

# Set trap to cleanup on exit
trap cleanup INT TERM EXIT

# Continuous loop
while true; do
    # Process pending logs
    process_pending_logs
    
    # Wait 1 second before next iteration
    sleep 1
done

exit 0
