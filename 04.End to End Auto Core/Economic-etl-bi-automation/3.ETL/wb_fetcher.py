from utils_retry import retry_call
import requests
import yaml
import mysql.connector
from datetime import datetime
from pathlib import Path
# Load system configuration (DB, API, etc.) from config.yaml
# Decouple configuration from code to enhance maintainability and reusability



ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "config" / "config.yaml"
    
def load_config():
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)
    
# Establish a MySQL connection using config parameters
# Disable autocommit to allow explicit transaction control and maintain data integrity
def get_db_conn(cfg):
    return mysql.connector.connect(
        host=cfg["mysql"]["host"],
        port=cfg["mysql"]["port"],
        user=cfg["mysql"]["user"],
        password=cfg["mysql"]["password"],
        database=cfg["mysql"]["database"],
        autocommit=False,
    )

def fetch_json_with_retry(url: str, params: dict, *, log=None, timeout=(5, 60)):
    """
    Fetch JSON from the World Bank API with retry support.
    """

    def _call():
        r = requests.get(url, params=params, timeout=timeout)
        r.raise_for_status()
        return r.json()

    return retry_call(
        _call,
        tries=3,
        base_sleep=1.0,
        max_sleep=8.0,
        logger=log,
        step_name="world_bank_fetch",
        retry_on=(requests.RequestException,),
    )


def fetch_world_bank_series(base_url, country_code, indicator_code, per_page=20000):
    """
    Retrieve time-series observations from the World Bank API
    and transform them into a standardized structure for database insertion.

    Returns:
    List[Tuple[str, str, str, float]]:
        (country_code, indicator_code, observation_date, value)

    Steps:
    1. Send HTTP GET request to the API endpoint
    2. Validate and parse JSON response
    3. Normalize annual date strings to YYYY-12-31 format
    4. Generate database-ready tuples for ETL processing
    """

    # Construct the API endpoint URL for the specified country and indicator
    url = f"{base_url}/country/{country_code}/indicator/{indicator_code}"

    # Define request parameters (JSON response format and pagination size)
    params = {"format": "json", "per_page": per_page}

    # Send HTTP GET request to the World Bank API with a timeout safeguard
    data = fetch_json_with_retry(url, params, log=None)



    # Validate response structure:
    # World Bank API returns a list in the form [metadata, observations].
    # If the structure is unexpected or observations are missing, return an empty list.
    if not isinstance(data, list) or len(data) < 2 or data[1] is None:
       return []

    rows = []

    # Iterate over observation records (data[1] contains the time-series entries)
    for obs in data[1]:

    # Extract year and value from each observation
       date_str = obs.get("date")  # typically a year string like "2022"
       value = obs.get("value")

    # Skip entries with missing date values
       if date_str is None:
          continue

    # Normalize annual year string into standardized date format
    # Using YYYY-12-31 ensures consistent date representation for yearly data
       obs_date = f"{date_str}-12-31"

    # Append formatted tuple for downstream DB insertion
       rows.append((country_code, indicator_code, obs_date, value))

    # Return transformed rows ready for ETL pipeline
       return rows

    
def upsert_observations(cur, rows):
    """
    Upsert observation rows into fact_observation.

    Args:
        cur: MySQL cursor (transaction controlled outside this function)
        rows: List of tuples in the format:
              (country_code, indicator_code, observation_date, value)

    Returns:
        (inserted_count, updated_count)

    Notes:
        - Uses INSERT ... SELECT to translate business keys (country_code, indicator_code)
          into surrogate keys (country_id, indicator_id).
        - Uses ON DUPLICATE KEY UPDATE to prevent duplicate rows and update values
          when the same (country_id, indicator_id, observation_date) already exists.
        - fact_observation must have a UNIQUE constraint on
          (country_id, indicator_id, observation_date).
    """

    # SQL upsert statement:
    # 1) Convert country_code/indicator_code to IDs via JOINs
    # 2) Insert the observation row
    # 3) If a duplicate key exists, update the value/source instead of inserting a new row
    sql = """
    INSERT INTO fact_observation (country_id, indicator_id, observation_date, value, source)
    SELECT c.country_id, i.indicator_id, %s, %s, 'world_bank'
    FROM dim_country c
    JOIN dim_indicator i
      ON i.indicator_code = %s AND i.source = 'world_bank'
    WHERE c.country_code = %s
    ON DUPLICATE KEY UPDATE
      value = VALUES(value),
      source = VALUES(source);
    """

    inserted = 0
    updated = 0

    # Execute upsert row-by-row (simple and explicit; can be optimized to executemany later)
    for country_code, indicator_code, obs_date, value in rows:
        cur.execute(sql, (obs_date, value, indicator_code, country_code))

        # MySQL cursor.rowcount behavior (common convention):
        # - 1: inserted a new row
        # - 2: updated an existing row (implementation-dependent, but commonly observed)
        if cur.rowcount == 1:
            inserted += 1
        elif cur.rowcount == 2:
            updated += 1

    # Return counts for ETL logging/monitoring
    return inserted, updated

def log_run(cur, started_at, ended_at, status, inserted, updated, error_message=None):
    """
    Log the execution result of an ETL run into etl_run_log.

    Args:
        cur: Active MySQL cursor (transaction handled externally)
        started_at: Timestamp when the ETL process started
        ended_at: Timestamp when the ETL process finished
        status: Execution status (e.g., 'success', 'failed')
        inserted: Number of newly inserted records
        updated: Number of updated records
        error_message: Optional error details (if execution failed)

    Purpose:
        - Provide execution traceability
        - Support monitoring and auditing
        - Enable failure diagnostics
        - Feed monitoring dashboard metrics
    """

    # Insert execution metadata into ETL log table
    # This enables system monitoring and operational transparency
    cur.execute(
        """
        INSERT INTO etl_run_log (
            started_at,
            ended_at,
            status,
            source_summary,
            records_inserted,
            records_updated,
            error_message
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """,
        (started_at, ended_at, status, "world_bank", inserted, updated, error_message),
    )
    
def run_world_bank_etl(cfg, cur):
    """
    Run World Bank ETL using existing fetch_world_bank_series + upsert_observations.
    Returns (inserted, updated). Transaction commit/rollback is handled by run_all.
    """
    base_url = cfg["world_bank"]["base_url"]
    countries = cfg["world_bank"]["countries"]
    indicators = cfg["world_bank"]["indicators"]
    per_page = cfg["world_bank"].get("per_page", 20000)

    total_ins, total_upd = 0, 0

    for c in countries:
        for ind in indicators:
            rows = fetch_world_bank_series(base_url, c, ind, per_page)
            if not rows:
                continue
            ins, upd = upsert_observations(cur, rows)
            total_ins += ins
            total_upd += upd

    return total_ins, total_upd


def main():
    """
    Main ETL orchestration function.

    Responsibilities:
        - Load configuration
        - Establish DB connection
        - Iterate over configured countries and indicators
        - Fetch data from World Bank API
        - Upsert observations into the database
        - Log execution status (success or failure)
        - Manage transaction control (commit / rollback)
        - Ensure resource cleanup

    This function acts as the entry point and coordinates
    all ETL pipeline components.
    """

    # Record ETL start time for monitoring and logging
    started_at = datetime.now()

    # Load configuration settings
    cfg = load_config()
    base_url = cfg["world_bank"]["base_url"]
    countries = cfg["world_bank"]["countries"]
    indicators = cfg["world_bank"]["indicators"]
    per_page = cfg["world_bank"].get("per_page", 20000)

    # Establish database connection and cursor
    conn = get_db_conn(cfg)
    cur = conn.cursor()

    # Initialize counters for monitoring metrics
    total_ins, total_upd = 0, 0

    try:
        # Iterate through configured countries and indicators
        for c in countries:
            for ind in indicators:

                # Fetch time-series data from API
                rows = fetch_world_bank_series(base_url, c, ind, per_page)

                # Skip if no data returned
                if not rows:
                    continue

                # Upsert data into fact table
                ins, upd = upsert_observations(cur, rows)
                total_ins += ins
                total_upd += upd

        # Record successful completion time
        ended_at = datetime.now()

        # Log successful ETL execution
        log_run(cur, started_at, ended_at, "success", total_ins, total_upd, None)

        # Commit transaction (persist all DB changes)
        conn.commit()

        print(f"[OK] inserted={total_ins}, updated={total_upd}")

    except Exception as e:
        # If any error occurs, rollback all changes
        ended_at = datetime.now()
        conn.rollback()

        # Attempt to log failure for monitoring visibility
        try:
            log_run(cur, started_at, ended_at, "failed", total_ins, total_upd, str(e))
            conn.commit()
        except Exception:
            pass

        # Re-raise exception for upstream handling
        raise

    finally:
        # Ensure DB resources are properly released
        cur.close()
        conn.close()


# Entry point guard: ensures script runs only when executed directly
if __name__ == "__main__":
    main()
