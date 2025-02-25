#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.env"
source "$SCRIPT_DIR/../utils/slog.sh"

mkdir -p "$TMP_DIR" "$LOG_DIR"

TOTAL_START_TIME=$(date +%s)

log_info "Fetching postes list from: $POSTES_CSV_URL"
POSTE_CSV=$(curl -s "$POSTES_CSV_URL")

if [ -z "$POSTE_CSV" ]; then
    log_error "Unable to fetch postes list."
    exit 1
fi

REQUEST_ID=$(date +%s%N)
TEMP_FILE="$TMP_DIR/postes_${REQUEST_ID}.csv"

#log_info "First 5 lines of the raw CSV file:"
#log_info "$POSTE_CSV" | head -n 5

log_info "Detecting columns and transforming to camelCase..."

# Extract header (first line)
HEADER=$(echo "$POSTE_CSV" | head -n 1)

# Function to convert to camelCase
camel_case() {
    echo "$1" | sed -E 's/([0-9])([a-zA-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]' | awk -F'_' '{
        result = $1;
        for (i = 2; i <= NF; i++) {
            result = result toupper(substr($i,1,1)) substr($i,2);
        }
        print result;
    }'
}

# Convert headers
CAMELCASE_HEADER="\"posteOuvert\""
for col in $(echo "$HEADER" | tr ';' '\n'); do
    CAMELCASE_HEADER+=",\"$(camel_case "$col")\""
done

log_info "Transformed columns: $CAMELCASE_HEADER"

# Process data and write to TEMP_FILE
{
    echo "$CAMELCASE_HEADER"
    echo "$POSTE_CSV" | tail -n +2 | awk -F';' -v OFS=',' '
        function format_date(date) {
            if (date == "" || date == "NULL") {
                return ""
            } else if (match(date, /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/)) {
                return date "T00:00:00.000Z"
            }
            return date
        }

        function quote(value) {
            if (value ~ /,/) {
                return "\"" value "\""
            }
            return value
        }

        {
            posteOuvert = ($6 == "" ? "true" : "false")
            datouvr = format_date($5)  # `datouvr` (5e colonne)
            datferm = format_date($6)  # `datferm` (6e colonne)

            print posteOuvert, $1, quote($2), quote($3), quote($4), datouvr, datferm, $7, $8, $9, $10, $11, $12
        }
    '
} > "$TEMP_FILE"


#log_info "First 5 lines of the processed CSV file:"
#head -n 5 "$TEMP_FILE"

log_info "Processed data written to: $TEMP_FILE"

# Ensure the staging table exists
log_info "Creating staging table if not exists..."
psql "$DB_URL" -A -t -c "CREATE TABLE IF NOT EXISTS staging_postes AS TABLE \"$POSTE_TABLE\" WITH NO DATA;" > /dev/null 2>&1
log_info "Staging table is ready."

log_info "Copying data to staging_postes..."
psql "$DB_URL" -c "\copy staging_postes ($CAMELCASE_HEADER) FROM '$TEMP_FILE' WITH CSV HEADER DELIMITER ','" > /dev/null 2>&1

COPIED_COUNT=$(psql "$DB_URL" -A -t -c "SELECT COUNT(*) FROM staging_postes;")
log_info "Number of rows copied to staging_postes: $COPIED_COUNT"

# Insert into the main table with upsert logic
log_info "Inserting into the main table Poste..."
INSERTED_COUNT=$(psql "$DB_URL" -A -t -c "
    WITH inserted AS (
        INSERT INTO \"$POSTE_TABLE\" ($CAMELCASE_HEADER)
        SELECT $CAMELCASE_HEADER FROM staging_postes
        ON CONFLICT (\"numPoste\")
        DO UPDATE SET $(echo "$CAMELCASE_HEADER" | awk -F',' '{for (i=2; i<=NF; i++) print $i" = EXCLUDED."$i","}' | sed '$s/,$//')
        RETURNING \"numPoste\"
    )
    SELECT COUNT(*) FROM inserted;
")

log_info "Number of rows inserted or updated: $INSERTED_COUNT"

log_info "Cleaning up staging_postes..."
psql "$DB_URL" -A -t -c "TRUNCATE TABLE staging_postes;" > /dev/null 2>&1
log_info "Staging table cleaned."

log_info "Deleting temp file: $TEMP_FILE..."
rm -f "$TEMP_FILE"
log_info "Temp file deleted."

TOTAL_END_TIME=$(date +%s)
TOTAL_DURATION=$((TOTAL_END_TIME - TOTAL_START_TIME))
log_success "Total execution time: $TOTAL_DURATION seconds."
