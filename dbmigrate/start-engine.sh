#!/bin/bash

DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_USER="logapp"
DB_PASS="logapp123"
DB_NAME="logdb"
LOG_FILE="dbmigrate.log"

echo "Engine started at $(date)" >> "$LOG_FILE"

while true
do
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N -e \
    "SELECT id, message FROM logs WHERE status='pending';" | while IFS=$'\t' read -r id command
    do
        echo "Running log id $id: $command at $(date)" >> "$LOG_FILE"

        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e \
        "UPDATE logs SET status='processing' WHERE id=$id;"

        output=$(eval "$command" 2>&1)
        exit_code=$?

        safe_output=$(echo "$output" | sed "s/'/''/g")
        safe_command=$(echo "$command" | sed "s/'/''/g")

        if [ $exit_code -eq 0 ]; then
            status="done"
            echo "SUCCESS id $id: $output" >> "$LOG_FILE"
        else
            status="error"
            echo "ERROR id $id: $output" >> "$LOG_FILE"
        fi

        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e \
        "UPDATE logs SET status='$status' WHERE id=$id;
         INSERT INTO execution_log (log_id, command, output, exit_code)
         VALUES ($id, '$safe_command', '$safe_output', $exit_code);"
    done

    sleep 5
done
