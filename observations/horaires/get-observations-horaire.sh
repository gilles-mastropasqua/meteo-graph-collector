#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../config.env"

mkdir -p "$TMP_DIR" "$LOG_DIR"

# Check if PERIOD is provided
if [ -z "$1" ]; then
    echo "❌ ERROR: Please specify a period (e.g., latest-2024-2025)"
    exit 1
fi

PERIOD="$1"

TOTAL_START_TIME=$(date +%s)

echo "🔍 Fetching file list for period $PERIOD..."
FILES_JSON=$(curl -s "$API_URL")
if [ -z "$FILES_JSON" ]; then
    echo "❌ ERROR: Unable to fetch file list."
    exit 1
fi

FILE_URLS=$(echo "$FILES_JSON" | jq -r ".data[].url | select(contains(\"$PERIOD\"))")
if [ -z "$FILE_URLS" ]; then
    echo "⚠️ No files found for period $PERIOD."
    exit 0
fi

echo "✅ Files found:"
echo "$FILE_URLS"

echo ""
echo "--------------------------------------------------------------"
echo ""

# Cleanup main table
# echo "🧹 Cleaning the main table: $OBSERVATIONS_HORAIRE_TABLE..."
# START_TIME=$(date +%s)
# psql "$DB_URL" -A -t -c "TRUNCATE TABLE \"$OBSERVATIONS_HORAIRE_TABLE\";" > /dev/null 2>&1
# END_TIME=$(date +%s)
# echo "✅ Main table cleaned in $((END_TIME - START_TIME)) seconds."

# Create staging table if not exists
echo "🛢️ Ensuring staging table exists..."
psql "$DB_URL" -A -t -c "CREATE TABLE IF NOT EXISTS staging_observations AS TABLE \"$OBSERVATIONS_HORAIRE_TABLE\" WITH NO DATA;" > /dev/null 2>&1
echo "✅ Staging table ready."
echo "🚀 Starting processing for period $PERIOD..."
echo ""
echo "--------------------------------------------------------------"
echo ""

TOTAL_INSERTED=0  # Counter for total inserted rows

# Process each file
for FILE_URL in $FILE_URLS; do
    START_TIME=$(date +%s)

    REQUEST_ID=$(date +%s%N)
    COMPRESSED_FILE="${TMP_DIR%/}/observations_${REQUEST_ID}.gz"
    CSV_FILE="${TMP_DIR%/}/observations_${REQUEST_ID}.csv"
    TEMP_FILE="${TMP_DIR%/}/observations_${REQUEST_ID}_transformed.csv"


    echo "📥 Downloading: $FILE_URL..."
    curl -s -o "$COMPRESSED_FILE" "$FILE_URL"

    if [ ! -s "$COMPRESSED_FILE" ]; then
        echo "❌ ERROR: File is empty or not downloaded."
        continue
    fi

    echo "📂 Decompressing file..."
    gunzip -c "$COMPRESSED_FILE" > "$CSV_FILE"

    if [ ! -s "$CSV_FILE" ]; then
        echo "❌ ERROR: Decompression failed."
        continue
    fi

    echo "🔄 Detecting column indexes..."

    ORIGINAL_HEADER=$(head -n 1 "$CSV_FILE")

    NUM_POSTE_INDEX=-1
    AAAAMMJJHH_INDEX=-1
    IFS=';' read -r -a HEADER_ARRAY <<< "$ORIGINAL_HEADER"

    for i in "${!HEADER_ARRAY[@]}"; do
        case "${HEADER_ARRAY[$i]}" in
            "NUM_POSTE") NUM_POSTE_INDEX=$i ;;
            "AAAAMMJJHH") AAAAMMJJHH_INDEX=$i ;;
        esac
    done

    if [ $NUM_POSTE_INDEX -eq -1 ] || [ $AAAAMMJJHH_INDEX -eq -1 ]; then
        echo "❌ ERROR: 'NUM_POSTE' or 'AAAAMMJJHH' not found."
        continue
    fi

    echo "✅ Columns detected: numPoste at $((NUM_POSTE_INDEX + 1)), aaaammjjhh at $((AAAAMMJJHH_INDEX + 1))"

    # Convert column names to camelCase
    camel_case() {
        echo "$1" | sed -E 's/([0-9])([a-zA-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]' | awk -F'_' '{
            result = $1;
            for (i = 2; i <= NF; i++) {
                result = result toupper(substr($i,1,1)) substr($i,2);
            }
            print result;
        }'
    }

    CAMELCASE_HEADER="dateObservation"
    for col in "${HEADER_ARRAY[@]}"; do
        CAMELCASE_HEADER+=";$(camel_case "$col")"
    done

    # Transform data
    {
        echo "$CAMELCASE_HEADER"
        tail -n +2 "$CSV_FILE" | awk -F';' -v OFS=';' -v numPosteIdx=$NUM_POSTE_INDEX -v aaaammjjhhIdx=$AAAAMMJJHH_INDEX '{
            rawDate = $(aaaammjjhhIdx + 1);
            year = substr(rawDate, 1, 4);
            month = substr(rawDate, 5, 2);
            day = substr(rawDate, 7, 2);
            hour = substr(rawDate, 9, 2);
            dateObs = sprintf("%04d-%02d-%02dT%02d:00:00.000Z", year, month, day, hour);

            gsub(/^ +| +$/, "", $(numPosteIdx + 1));
            $(numPosteIdx + 1) = sprintf("%08d", $(numPosteIdx + 1));

            print dateObs, $0;
        }'
    } > "$TEMP_FILE"

    echo "🔹 Temporary file generated: $TEMP_FILE"

    DB_COLUMNS=$(echo "$CAMELCASE_HEADER" | awk -F';' '{for (i=1; i<=NF; i++) printf "\"%s\"%s", $i, (i==NF ? "" : ",")}')


    echo "📥 Copying data to staging_observations..."
    psql "$DB_URL" -A -t -c "\copy staging_observations ($DB_COLUMNS) FROM '$TEMP_FILE' WITH CSV HEADER DELIMITER ';'" > /dev/null 2>&1

    COPIED_COUNT=$(psql "$DB_URL" -A -t -c "SELECT COUNT(*) FROM staging_observations;")
    echo "✅ Rows copied to staging: $COPIED_COUNT"

    BEFORE_COUNT=$(psql "$DB_URL" -A -t -c "SELECT COUNT(*) FROM \"$OBSERVATIONS_HORAIRE_TABLE\";")
    echo "📊 Rows in $OBSERVATIONS_HORAIRE_TABLE before insertion: $BEFORE_COUNT"

    echo "🛢️ Inserting data into main table..."
    INSERTED=$(psql "$DB_URL" -A -t -c "
        WITH inserted AS (
            INSERT INTO \"$OBSERVATIONS_HORAIRE_TABLE\" ($DB_COLUMNS)
            SELECT $DB_COLUMNS FROM staging_observations
            WHERE \"numPoste\" IN (SELECT \"numPoste\" FROM \"$POSTE_TABLE\")
            ON CONFLICT (\"numPoste\", \"dateObservation\")
            DO UPDATE SET $(echo "$DB_COLUMNS" | awk -F',' '{for (i=2; i<=NF; i++) print $i" = EXCLUDED."$i","}' | sed '$s/,$//')
            RETURNING *
        )
        SELECT COUNT(*) FROM inserted;
    ")
    echo "✅ Rows inserted or updated: $INSERTED"
    TOTAL_INSERTED=$((TOTAL_INSERTED + INSERTED))

    AFTER_COUNT=$(psql "$DB_URL" -A -t -c "SELECT COUNT(*) FROM \"$OBSERVATIONS_HORAIRE_TABLE\";")
    echo "📊 Rows in $OBSERVATIONS_HORAIRE_TABLE after insertion: $AFTER_COUNT"

    echo "🧹 Cleaning up..."
    psql "$DB_URL" -A -t -c "TRUNCATE TABLE staging_observations;" > /dev/null 2>&1
    rm -f "$COMPRESSED_FILE" "$CSV_FILE" "$TEMP_FILE"

    END_TIME=$(date +%s)
    echo "✅ Processing completed for $FILE_URL in $((END_TIME - START_TIME)) seconds."
    echo ""
    echo "--------------------------------------------------------------"
    echo ""

done

# Calculate total execution time
TOTAL_END_TIME=$(date +%s)
echo "🚀 Total execution time: $((TOTAL_END_TIME - TOTAL_START_TIME)) seconds."
echo "✅ Total rows inserted across all files: $TOTAL_INSERTED"

