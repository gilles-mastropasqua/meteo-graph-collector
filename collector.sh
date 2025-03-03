#!/bin/bash

export TERM=xterm

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration variables
source "$SCRIPT_DIR/config.env"
source "$SCRIPT_DIR/utils/slog.sh"

# Ensure the scripts are executable
chmod +x "$SCRIPT_DIR/postes/get-postes.sh"
chmod +x "$SCRIPT_DIR/observations/horaires/get-observations-horaire.sh"

# Get the current timestamp for log filenames
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Ensure necessary directories exist
mkdir -p "$SCRIPT_DIR/postes/tmp" "$SCRIPT_DIR/postes/logs"
mkdir -p "$SCRIPT_DIR/observations/horaires/tmp" "$SCRIPT_DIR/observations/horaires/logs"

PERIOD=${1:-latest}

# Execute get-postes.sh and log output
log_info "Running postes collector..."
"$SCRIPT_DIR/postes/get-postes.sh" > "$SCRIPT_DIR/postes/logs/postes_$TIMESTAMP.log" 2>&1
log_success "Postes collection completed."

# Execute get-observations-horaire.sh and log output
log_info "Running observations collector... (this may take a while)"
"$SCRIPT_DIR/observations/horaires/get-observations-horaire.sh" "$PERIOD" > "$SCRIPT_DIR/observations/horaires/logs/observations_$TIMESTAMP.log" 2>&1
log_success "Observations collection completed."

# Print completion message with timestamp
log_success "All collections completed at $(date)."
