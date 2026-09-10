import yaml
from datetime import datetime

from db import get_conn
from logger import get_logger
from snapshot import SNAPSHOT_SQL
from crawler_stub import run_crawling
from wb_fetcher import run_world_bank_etl

# Load system configuration (DB, API, etc.) from config.yaml
# Decouple configuration from code to enhance maintainability and reusability
def load_cfg(path=r"D:\01.Project\02.Power_BI_Project\Upwork big project\Economic-etl-bi-automation\config\config.yaml"):
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def log_run(cur, started, ended, status, inserted, updated, err=None, source="run_all"):
    """
    Logs a single ETL execution into the etl_run_log table.

    Parameters:
        cur        : Active database cursor object
        started    : Datetime when the ETL process started
        ended      : Datetime when the ETL process finished
        status     : Execution status ("success", "failed", etc.)
        inserted   : Number of records inserted during this run
        updated    : Number of records updated during this run
        err        : Optional error message (None if successful)
        source     : Source identifier of the run (default = "run_all")

    This function records execution metadata for monitoring and auditing.
    """
    cur.execute(
        """
        INSERT INTO etl_run_log (started_at, ended_at, status, source_summary, records_inserted, records_updated, error_message)
        VALUES (%s,%s,%s,%s,%s,%s,%s)
        """,
        (started, ended, status, source, inserted, updated, err),
    )
def main():
    """
    Main orchestration function for the end-to-end ETL pipeline.

    Responsibilities:
        - Initialize logger and configuration
        - Establish database connection
        - Execute API ETL (World Bank)
        - Execute crawling ETL
        - Refresh daily snapshot table
        - Log execution results
        - Handle errors with rollback and failure logging

    This function serves as the central controller of the entire ETL workflow.
    """

    # Initialize logger for monitoring execution
    log = get_logger("run_all")

    # Load configuration (DB settings, API settings, etc.)
    cfg = load_cfg()

    # Capture start time for ETL run logging
    started = datetime.now()

    # Counters for tracking inserted and updated rows
    inserted = 0
    updated = 0

    # Establish database connection and cursor
    conn = get_conn(cfg)
    cur = conn.cursor()

    try:
        # --- Step 1: Run World Bank ETL ---
        # Fetch data from API, transform, and upsert into DB
        wi, wu = run_world_bank_etl(cfg, cur)
        inserted += wi
        updated += wu
        log.info(f"WorldBank: inserted={wi}, updated={wu}")

        # --- Step 2: Run Crawling ETL ---
        # Scrape external data and insert/update into DB
        ci, cu = run_crawling(cfg, conn, cur)
        inserted += ci
        updated += cu

        # --- Step 3: Refresh Daily Snapshot ---
        # Update latest values for monitoring and reporting
        cur.execute(SNAPSHOT_SQL)

        # Capture end time after successful execution
        ended = datetime.now()

        # Log successful ETL run into etl_run_log table
        log_run(
            cur,
            started,
            ended,
            "success",
            inserted,
            updated,
            None,
            "world_bank+crawl+snapshot"
        )

        # Commit all changes to the database
        conn.commit()

        log.info(f"OK inserted={inserted} updated={updated}")

    except Exception as e:
        # If any error occurs:
        # 1. Roll back all database changes
        conn.rollback()

        ended = datetime.now()

        # Attempt to log failure details
        try:
            log_run(
                cur,
                started,
                ended,
                "failed",
                inserted,
                updated,
                str(e),
                "run_all"
            )
            conn.commit()
        except Exception:
            # If logging also fails, silently ignore
            pass

        # Re-raise the exception for visibility
        raise

    finally:
        # Always close cursor and connection
        cur.close()
        conn.close()


# Entry point of the script
if __name__ == "__main__":
    main()

