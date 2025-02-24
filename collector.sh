#!/bin/bash

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration variables
source "$SCRIPT_DIR/config.env"

# Ensure the scripts are executable
chmod +x "$SCRIPT_DIR/postes/get-postes.sh"
chmod +x "$SCRIPT_DIR/observations/horaires/get-observations-horaire.sh"

# Get the current timestamp for log filenames
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Ensure necessary directories exist
mkdir -p "$SCRIPT_DIR/postes/tmp" "$SCRIPT_DIR/postes/logs"
mkdir -p "$SCRIPT_DIR/observations/horaires/tmp" "$SCRIPT_DIR/observations/horaires/logs"

# Execute get-postes.sh and log output
echo "🚀 Running postes collector..."
"$SCRIPT_DIR/postes/get-postes.sh" > "$SCRIPT_DIR/postes/logs/postes_$TIMESTAMP.log" 2>&1
echo "✅ Postes collection completed."

# Execute get-observations-horaire.sh and log output
echo "🚀 Running observations collector..."
"$SCRIPT_DIR/observations/horaires/get-observations-horaire.sh" latest-2024-2025 > "$SCRIPT_DIR/observations/horaires/logs/observations_$TIMESTAMP.log" 2>&1
echo "✅ Observations collection completed."

# Print completion message with timestamp
echo "🎯 All collections completed at $(date)."
