import yaml
import mysql.connector
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "config" / "config.yaml"

SNAPSHOT_SQL = """
CREATE OR REPLACE VIEW v_latest_observation AS
SELECT
    c.country_name,
    i.indicator_name,
    f.observation_date,
    f.value,
    f.source
FROM fact_observation f
JOIN dim_country c
    ON f.country_id = c.country_id
JOIN dim_indicator i
    ON f.indicator_id = i.indicator_id
WHERE f.observation_date = (
    SELECT MAX(f2.observation_date)
    FROM fact_observation f2
    WHERE f2.country_id = f.country_id
      AND f2.indicator_id = f.indicator_id
);
"""

def load_cfg():
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def get_conn(cfg):
    return mysql.connector.connect(
        host=cfg["mysql"]["host"],
        port=cfg["mysql"]["port"],
        user=cfg["mysql"]["user"],
        password=cfg["mysql"]["password"],
        database=cfg["mysql"]["database"],
        autocommit=False,
    )

def main():
    cfg = load_cfg()
    conn = get_conn(cfg)
    cur = conn.cursor()

    try:
        cur.execute(SNAPSHOT_SQL)
        conn.commit()
        print("[OK] Snapshot refreshed: v_latest_observation")

    except Exception as e:
        conn.rollback()
        print("[FAILED] Snapshot refresh failed")
        raise e

    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    main()