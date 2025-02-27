# meteo-graph-collector

This project is a **data collection system** that fetches and processes meteorological data from **Météo-France**. It consists of shell scripts that retrieve **weather station metadata (postes)** and **hourly weather observations** and store them in a **PostgreSQL database**.
This collector is designed to work with the [meteo-graph-api](https://github.com/gilles-mastropasqua/meteo-graph-api) repository.
## Features

- **Fetches station metadata** (postes) from official Météo-France sources.
- **Collects hourly weather observations** for a specified period.
- **Processes data** (date formatting, filtering).
- **Stores data in PostgreSQL**, using staging tables for upserts.
- **Logs execution details** for monitoring.
- **Designed to run periodically** (e.g., every hour with `cron`).

---

## Setup

### Clone the repository
```sh
git clone https://github.com/gilles-mastropasqua/METEO-FRANCE-API-COLLECTOR.git
cd METEO-FRANCE-API-COLLECTOR
```

### Configure the environment
```sh
cp config-example.env config.env
```

Edit **config.env**:
```
# Database connection
DB_URL="postgresql://postgres:yourpassword@192.168.1.114:5432/meteo_data"

# API URLs
API_URL="https://www.data.gouv.fr/api/2/datasets/6569b4473bedf2e7abad3b72/resources/?page=1&page_size=10000"
POSTES_CSV_URL="https://object.files.data.gouv.fr/meteofrance/data/synchro_ftp/BASE/POSTES/POSTES_MF.csv"

# Other configurations
OBSERVATIONS_HORAIRE_TABLE="ObservationHoraire"
POSTE_TABLE="Poste"
TMP_DIR="$SCRIPT_DIR/tmp"
LOG_DIR="$SCRIPT_DIR/logs"
```

### Install dependencies
Ensure **PostgreSQL** and `psql` are installed on your system.

For Debian/Ubuntu:
```sh
sudo apt update && sudo apt install postgresql postgresql-client -y
```

For macOS (using Homebrew):
```sh
brew install postgresql
```

---

## Database Setup

Before running the collector, you need to create the required **PostgreSQL tables**.

### Ensure your PostgreSQL server is running
```sh
sudo systemctl start postgresql   # Linux
brew services start postgresql    # macOS
```

### Run the database setup script
```sh
cd database
chmod +x setup-database.sh
./setup-database.sh
```
This script will:
- Create necessary tables if they don’t exist.
- Apply the latest schema (`schema.sql`).
- Log output in `database/logs/schema.log`.

To reset the database, run:
```sh
psql "$DB_URL" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
./setup-database.sh
```

---

## Running the Data Collection

### Make scripts executable
```sh
chmod +x collector.sh
chmod +x postes/get-postes.sh
chmod +x observations/horaires/get-observations-horaire.sh
```

### Run the data collection manually
```sh
./collector.sh
```

To run individual scripts:
```sh
./postes/get-postes.sh
./observations/horaires/get-observations-horaire.sh latest-2024-2025
```

---

## Automate with cron

To run the collector **every hour**, add this to your crontab:
```sh
0 * * * * /path/to/collector.sh >> /path/to/logs/collector.log 2>&1
```

Edit your cron jobs with:
```sh
crontab -e
```

---

## License
For details, see the [LICENSE](LICENSE) file.


