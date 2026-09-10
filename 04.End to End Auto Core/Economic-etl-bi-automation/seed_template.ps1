# =========================
# End-to-End Template Seeder
# Run this in project root:
#   economic-etl-bi-automation\
# =========================

$ErrorActionPreference = "Stop"

function Ensure-Dir($path) {
  if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

function Write-File($path, $content) {
  $dir = Split-Path $path -Parent
  if ($dir -and -not (Test-Path $dir)) { Ensure-Dir $dir }
  Set-Content -Path $path -Value $content -Encoding UTF8
}

# --- Ensure core folders exist
$dirs = @(
  "0_docs",
  "1_data_raw\api",
  "1_data_raw\crawl",
  "2_database",
  "3_etl",
  "4_powerquery",
  "5_powerbi\screenshots",
  "6_reporting\templates",
  "6_reporting\outputs",
  "7_scheduler",
  "config",
  "logs"
)

$dirs | ForEach-Object { Ensure-Dir $_ }

# --- .gitkeep placeholders (so folders survive on GitHub)
Write-File "1_data_raw\api\.gitkeep" ""
Write-File "1_data_raw\crawl\.gitkeep" ""
Write-File "5_powerbi\screenshots\.gitkeep" ""
Write-File "6_reporting\templates\.gitkeep" ""
Write-File "6_reporting\outputs\.gitkeep" ""
Write-File "logs\.gitkeep" ""

# --- Root files
Write-File "README.md" @"
# Global Economic Monitoring & Automated Reporting System

End-to-end BI automation project integrating:
- REST API (World Bank)
- MySQL (star-schema friendly tables)
- Power BI (monitoring + analysis)
- Daily snapshot + ETL run logging
- (Optional) crawling + PDF/email automation

## Quick Start
1) Configure: `config/config.yaml`
2) Run ETL:
   - `python 3_etl\wb_fetcher.py`
   - or `python 3_etl\run_all.py`
3) Verify DB:
   - `SELECT COUNT(*) FROM fact_observation;`
4) Refresh Power BI report and check the Monitoring page.
"@

Write-File "requirements.txt" @"
requests
pyyaml
mysql-connector-python
"@

Write-File ".gitignore" @"
# secrets
config/config.yaml

# local outputs
logs/
1_data_raw/
6_reporting/outputs/

# power bi
*.pbix

# python
__pycache__/
*.pyc
.venv/
.env
"@

# --- Docs
Write-File "0_docs\project_scope.md" @"
# Project Scope
- Sources: World Bank API (+ optional crawling)
- Storage: MySQL (economic_monitoring_db)
- BI: Power BI Desktop (star schema / monitoring)
- Output: PDF + Email (optional)
- Automation: Daily scheduler + monitoring page
"@

Write-File "0_docs\architecture.md" @"
# Architecture

[World Bank API] ---> [Python ETL] ---> [MySQL] ---> [Power Query] ---> [Power BI]
                                  \--> [etl_run_log + daily_snapshot] ---> [Monitoring Page]
(Optional) [Crawling] ------------/
(Optional) [PDF/Email] <----------/
"@

Write-File "0_docs\data_model.md" @"
# Data Model (Core Tables)
- dim_country
- dim_indicator
- fact_observation
- etl_run_log
- daily_snapshot
"@

Write-File "0_docs\demo_script.md" @"
# Demo Script (60~90 sec)
1) Run ETL: `python 3_etl\run_all.py`
2) Show MySQL: latest row in etl_run_log
3) Refresh PBIX
4) Show Monitoring cards updating (Last ETL Run / Latest Inserted / Latest Snapshot)
5) Show trend chart with slicers (country + indicator)
"@

# --- Database helper queries
Write-File "2_database\queries_debug.sql" @"
USE economic_monitoring_db;

SELECT COUNT(*) AS fact_rows FROM fact_observation;

SELECT *
FROM etl_run_log
ORDER BY run_id DESC
LIMIT 5;

SELECT *
FROM daily_snapshot
ORDER BY snapshot_id DESC
LIMIT 5;
"@

Write-File "2_database\seed.sql" @"
USE economic_monitoring_db;

INSERT INTO dim_country (country_code, country_name)
VALUES
  ('USA', 'United States'),
  ('KOR', 'South Korea'),
  ('JPN', 'Japan'),
  ('DEU', 'Germany')
ON DUPLICATE KEY UPDATE
  country_name = VALUES(country_name);

-- Indicators (World Bank)
INSERT INTO dim_indicator (indicator_code, indicator_name, source, frequency, unit)
VALUES
  ('NY.GDP.MKTP.CD', 'GDP (current US$)', 'world_bank', 'annual', 'USD'),
  ('FP.CPI.TOTL', 'Consumer price index (2010=100)', 'world_bank', 'annual', 'index'),
  ('SL.UEM.TOTL.ZS', 'Unemployment, total (% of total labor force)', 'world_bank', 'annual', '%'),
  ('FR.INR.RINR', 'Real interest rate (%)', 'world_bank', 'annual', '%'),
  ('NE.EXP.GNFS.CD', 'Exports of goods and services (current US$)', 'world_bank', 'annual', 'USD'),
  ('NE.IMP.GNFS.CD', 'Imports of goods and services (current US$)', 'world_bank', 'annual', 'USD')
ON DUPLICATE KEY UPDATE
  indicator_name = VALUES(indicator_name),
  frequency      = VALUES(frequency),
  unit           = VALUES(unit);
"@

# --- Config example (safe to commit)
Write-File "config\config.example.yaml" @"
mysql:
  host: "127.0.0.1"
  port: 3307
  user: "root"
  password: "YOUR_MYSQL_PASSWORD"
  database: "economic_monitoring_db"

world_bank:
  base_url: "https://api.worldbank.org/v2"
  countries:
    - "USA"
    - "KOR"
    - "JPN"
    - "DEU"
  indicators:
    - "NY.GDP.MKTP.CD"
    - "FP.CPI.TOTL"
    - "SL.UEM.TOTL.ZS"
    - "FR.INR.RINR"
    - "NE.EXP.GNFS.CD"
    - "NE.IMP.GNFS.CD"
  per_page: 20000
"@

# Create config.yaml only if it doesn't exist (avoid overwriting your real password file)
if (-not (Test-Path "config\config.yaml")) {
  Copy-Item "config\config.example.yaml" "config\config.yaml"
}

# --- ETL modules
Write-File "3_etl\db.py" @"
import mysql.connector

def get_conn(cfg: dict):
    return mysql.connector.connect(
        host=cfg["mysql"]["host"],
        port=cfg["mysql"]["port"],
        user=cfg["mysql"]["user"],
        password=cfg["mysql"]["password"],
        database=cfg["mysql"]["database"],
        autocommit=False,
    )
"@

Write-File "3_etl\logger.py" @"
import logging
from pathlib import Path
from datetime import datetime

def get_logger(name: str = "etl"):
    Path("logs").mkdir(exist_ok=True)
    log_file = Path("logs") / f"etl_{datetime.now():%Y-%m-%d}.log"

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[
            logging.FileHandler(log_file, encoding="utf-8"),
            logging.StreamHandler()
        ],
    )
    return logging.getLogger(name)
"@

Write-File "3_etl\snapshot.py" @"
SNAPSHOT_SQL = """
INSERT INTO daily_snapshot (snapshot_date, country_id, indicator_id, latest_value, latest_obs_date)
SELECT CURDATE(), f.country_id, f.indicator_id, f.value, f.observation_date
FROM fact_observation f
JOIN (
  SELECT country_id, indicator_id, MAX(observation_date) AS max_date
  FROM fact_observation
  GROUP BY country_id, indicator_id
) m
  ON f.country_id=m.country_id AND f.indicator_id=m.indicator_id AND f.observation_date=m.max_date
ON DUPLICATE KEY UPDATE
  latest_value=VALUES(latest_value),
  latest_obs_date=VALUES(latest_obs_date);
"""
"@

Write-File "3_etl\crawler_stub.py" @"
def run_crawling(cfg: dict, conn, cur):
    # Optional: implement crawling here
    # Return: (records_inserted, records_updated)
    return 0, 0
"@

Write-File "3_etl\run_all.py" @"
import yaml
from datetime import datetime

from db import get_conn
from logger import get_logger
from snapshot import SNAPSHOT_SQL
from crawler_stub import run_crawling

def load_cfg(path="config/config.yaml"):
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def log_run(cur, started, ended, status, inserted, updated, err=None, source="run_all"):
    cur.execute(
        \"\"\"
        INSERT INTO etl_run_log (started_at, ended_at, status, source_summary, records_inserted, records_updated, error_message)
        VALUES (%s,%s,%s,%s,%s,%s,%s)
        \"\"\",
        (started, ended, status, source, inserted, updated, err),
    )

def main():
    log = get_logger("run_all")
    cfg = load_cfg()

    started = datetime.now()
    inserted = 0
    updated = 0

    conn = get_conn(cfg)
    cur = conn.cursor()

    try:
        # TODO: call your wb_fetcher logic here if you want one-button full run.
        # For now, run_all handles: (optional) crawling + snapshot + logging

        ci, cu = run_crawling(cfg, conn, cur)
        inserted += ci
        updated += cu

        cur.execute(SNAPSHOT_SQL)

        ended = datetime.now()
        log_run(cur, started, ended, "success", inserted, updated, None, "crawl+snapshot")
        conn.commit()
        log.info(f"OK inserted={inserted} updated={updated}")

    except Exception as e:
        conn.rollback()
        ended = datetime.now()
        try:
            log_run(cur, started, ended, "failed", inserted, updated, str(e), "run_all")
            conn.commit()
        except Exception:
            pass
        raise

    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    main()
"@

# --- Power Query placeholders
Write-File "4_powerquery\README.md" @"
# Power Query (M) Folder
Store exported M scripts here:
- fact_observation.m
- dim_country.m
- dim_indicator.m
- etl_run_log.m
- daily_snapshot.m

Tip: Keep query names clean (no db prefix).
"@

Write-File "4_powerquery\fact_observation.m" "// TODO: paste M code exported from Power Query"
Write-File "4_powerquery\dim_country.m" "// TODO"
Write-File "4_powerquery\dim_indicator.m" "// TODO"
Write-File "4_powerquery\etl_run_log.m" "// TODO"
Write-File "4_powerquery\daily_snapshot.m" "// TODO"

# --- Power BI notes
Write-File "5_powerbi\notes.md" @"
# Power BI Notes
Pages:
1) Executive Overview (trend + slicers)
2) System Monitoring (Last ETL Run / Latest Inserted / Latest Snapshot + log table)

Measures:
- Indicator Value
- Chart Title (dynamic)
- Last ETL Run
- Latest Inserted
- Latest Snapshot
"@

# --- Reporting stubs
Write-File "6_reporting\build_pdf.py" @"
# TODO: build PDF report (ReportLab)
# Plan: 1-2 pages summary + (optional) embed dashboard screenshot
"@

Write-File "6_reporting\email_sender.py" @"
# TODO: send email with PDF attachment (SMTP)
"@

# --- Scheduler guide
Write-File "7_scheduler\windows_task_scheduler_guide.md" @"
# Daily Run (Windows Task Scheduler)
Recommended:
- Program/script: python
- Add arguments: 3_etl\\run_all.py
- Start in: <project_root>

Trigger:
- Daily at 09:00 (or 원하는 시간)

Check:
- logs\\etl_YYYY-MM-DD.log
- Power BI Monitoring page cards update after refresh
"@

Write-Host "✅ Template files created successfully!"
Write-Host "Next: (1) edit config\config.yaml password/port (2) pip install -r requirements.txt"

