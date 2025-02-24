# 🌍 METEO-FRANCE API COLLECTOR

This project is a **data collection system** that fetches and processes meteorological data from **Météo-France**. It consists of shell scripts that retrieve **weather station metadata (postes)** and **hourly weather observations** and store them in a **PostgreSQL database**.

## 📌 Features

- 🛰 **Fetches station metadata** (postes) from official Météo-France sources.
- ⏳ **Collects hourly weather observations** for a specified period.
- 🔄 **Processes data** (date formatting, filtering).
- 🛢 **Stores data in PostgreSQL**, using staging tables for upserts.
- 📜 **Logs execution details** for monitoring.
- 🕒 **Designed to run periodically** (e.g., every hour with `cron`).

---

## ⚙️ Setup

### 1️⃣ Clone the repository
```sh
git clone https://github.com/gilles-mastropasqua/METEO-FRANCE-API-COLLECTOR.git
cd METEO-FRANCE-API-COLLECTOR
```
### 2️⃣ Configure the environment
```sh
cp config-example.env config.env
```

Edit config.env:

```
# Database connection
DB_URL="postgresql://postgres:yourpassword@192.168.1.114:5432/meteo_data"

# API URL
API_URL="https://www.data.gouv.fr/api/2/datasets/6569b4473bedf2e7abad3b72/resources/?page=1&page_size=10000"

POSTES_CSV_URL="https://object.files.data.gouv.fr/meteofrance/data/synchro_ftp/BASE/POSTES/POSTES_MF.csv"

# Other configurations
OBSERVATIONS_HORAIRE_TABLE="ObservationHoraire"
POSTE_TABLE="Poste"
TMP_DIR="$SCRIPT_DIR/tmp"
LOG_DIR="$SCRIPT_DIR/logs"
```

### 3️⃣ Make scripts executable
```sh
chmod +x collector.sh
chmod +x postes/get-postes.sh
chmod +x observations/horaires/get-observations-horaire.sh
```

### 4️⃣ Run the data collection

To execute manually:
```sh
./collector.sh
```

To run individual scripts:
```sh
./postes/get-postes.sh
./observations/horaires/get-observations-horaire.sh latest-2024-2025
```

---

## 🕒 Automate with cron
To run the collector every hour, add this to your crontab:
```sh
0 * * * * /path/to/collector.sh >> /path/to/logs/collector.log 2>&1
```
Edit your cron jobs with:
```sh
crontab -e
``
