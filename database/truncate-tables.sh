#!/bin/bash

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables
source "$SCRIPT_DIR/../config.env"
source "$SCRIPT_DIR/../utils/slog.sh"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Log file for cleanup operations
LOG_FILE="$LOG_DIR/cleanup.log"

# Function to execute a SQL command and log the output
truncate_tables() {
    local TABLE_NAME=$1
    log_info "Cleaning table: $TABLE_NAME..."

    psql "$DB_URL" -c "TRUNCATE TABLE \"$TABLE_NAME\" RESTART IDENTITY CASCADE;" >> "$LOG_FILE" 2>&1
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        log_success "Successfully cleaned table: $TABLE_NAME."
    else
        log_error "Failed to clean table: $TABLE_NAME. Check logs for details: $LOG_FILE"
    fi
}

# Start cleanup process
log_info "Starting database cleanup..."

# Clean ObservationHoraire table
truncate_tables "$OBSERVATIONS_HORAIRE_TABLE"

# Clean Poste table
truncate_tables "$POSTE_TABLE"

log_success "Database cleanup completed successfully!"
