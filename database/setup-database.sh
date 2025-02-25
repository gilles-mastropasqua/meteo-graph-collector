#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.env"
source "$SCRIPT_DIR/../utils/slog.sh"

SCHEMA_FILE="$SCRIPT_DIR/schema.sql"

LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/schema.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

log_info "Setting up PostgreSQL database..."
log_info "Applying database schema from $SCHEMA_FILE..."

psql "$DB_URL" -f "$SCHEMA_FILE" >> "$LOG_FILE" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    log_success "Database schema applied successfully!"
else
    log_error "Failed to apply database schema. Check logs for details: $LOG_FILE"
    exit $EXIT_CODE
fi
