#!/bin/bash

DB_HOST="127.0.0.1"
DB_USER="root"
DB_PASS="rootpassword"
DB_NAME="logdb"

STAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="backup-$STAMP.sql"

echo "Running:"
echo "mysqldump -h $DB_HOST -u $DB_USER -p******** $DB_NAME > $FILE"

mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$FILE"

echo "Backup created: $FILE"
