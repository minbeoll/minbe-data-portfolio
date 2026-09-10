import subprocess
from pathlib import Path
import streamlit as st
import mysql.connector
import yaml
import pandas as pd
import mysql.connector
from pathlib import Path
import os
from datetime import datetime

if "pb_refresh_time" not in st.session_state:
    st.session_state.pb_refresh_time = None

ROOT = Path(r"D:\01.Project\02.Power_BI_Project\Upwork big project\Economic-etl-bi-automation")

CONFIG_PATH = ROOT / "config" / "config.yaml"
ETL_DIR = ROOT / "3.ETL"
LOG_DIR = ETL_DIR / "logs"

def load_cfg():
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

cfg = load_cfg()


PROJECT = cfg.get("project", {})

ETL_SCRIPT = PROJECT.get("etl_script", "run_all.py")
PBIX_FILE = PROJECT.get("pbix_file", "world_bank_dashboard.pbix")

RUN_ALL = ETL_DIR / ETL_SCRIPT

PBIX_PATH = ROOT / "5.powerbi" / PBIX_FILE

def get_latest_etl():
    conn = mysql.connector.connect(
        host=cfg["mysql"]["host"],
        port=cfg["mysql"]["port"],
        user=cfg["mysql"]["user"],
        password=cfg["mysql"]["password"],
        database=cfg["mysql"]["database"],
    )

    cur = conn.cursor(dictionary=True)

    cur.execute("""
        SELECT
            started_at,
            ended_at,
            status,
            records_inserted,
            records_updated,
            TIMESTAMPDIFF(SECOND, started_at, ended_at) AS duration_sec
        FROM etl_run_log
        ORDER BY started_at DESC
        LIMIT 1
    """)

    row = cur.fetchone()

    cur.close()
    conn.close()

    return row

st.set_page_config(page_title="AUTO_CORE Control Panel", layout="wide")

project_name = cfg.get("project", {}).get("name", "AUTO_CORE Control Panel")
project_subtitle = cfg.get("project", {}).get("subtitle", "ETL Automation System")

st.title(project_name)
st.caption(project_subtitle)

st.subheader("Project Information")

p1, p2, p3 = st.columns(3)

with p1:
    st.metric("Database", cfg["mysql"]["database"])

with p2:
    st.metric("ETL Script", "run_all.py")

with p3:
    st.metric("PBIX", Path(PBIX_PATH).name)

st.write("Config File")
st.code(CONFIG_PATH)

st.write("ETL Folder")
st.code(str(ETL_DIR))

c1, c2, c3, c4 = st.columns(4)

with c1:
    if st.button("Open Config", use_container_width=True):
        os.startfile(CONFIG_PATH)

with c2:
    if st.button("Open ETL Folder", use_container_width=True):
        os.startfile(ETL_DIR)

with c3:
    if st.button("Open Logs", use_container_width=True):
        os.startfile(LOG_DIR)

with c4:
    if st.button("Open Power BI", use_container_width=True):
        os.startfile(PBIX_PATH)


if "pb_refresh_time" not in st.session_state:
    st.session_state.pb_refresh_time = None
     
if st.button("Refresh Dashboard", use_container_width=True):
    st.rerun()

latest = get_latest_etl()
last_refresh = latest["ended_at"]
    
st.session_state.pb_refresh_time = datetime.now()

    
if st.session_state.pb_refresh_time:
    st.metric(
        "Power BI Refresh",
        st.session_state.pb_refresh_time.strftime("%Y-%m-%d %H:%M:%S")
    )
else:
    st.metric("Power BI Refresh", "Not refreshed")
    
c1, c2, c3, c4 = st.columns(4)

with c1:
    st.metric("Inserted", latest["records_inserted"])

with c2:
    st.metric("Updated", latest["records_updated"])

with c3:
    st.metric("Duration(sec)", latest["duration_sec"])

with c4:
    st.metric("Last Refresh", str(last_refresh))
    




def run_script(script_name):
    script_path = ETL_DIR / script_name

    result = subprocess.run(
        ["python", str(script_path)],
        cwd=str(ETL_DIR),
        capture_output=True,
        text=True
    )

    return result

st.subheader("Pipeline Control")

b1, b2, b3, b4 = st.columns(4)

with b1:
    if st.button("Run API", use_container_width=True):
        result = run_script("wb_fetcher.py")
        if result.returncode == 0:
            st.success("API ETL completed")
            st.code(result.stdout)
        else:
            st.error("API ETL failed")
            st.code(result.stderr)

with b2:
    if st.button("Run Crawl", use_container_width=True):
        result = run_script("crawler_stub.py")
        if result.returncode == 0:
            st.success("Crawl completed")
            st.code(result.stdout)
        else:
            st.error("Crawl failed")
            st.code(result.stderr)

with b3:
    if st.button("Run Snapshot", use_container_width=True):
        result = run_script("snapshot.py")
        if result.returncode == 0:
            st.success("Snapshot completed")
            st.code(result.stdout)
        else:
            st.error("Snapshot failed")
            st.code(result.stderr)

with b4:
    if st.button("Run All", use_container_width=True):
        result = run_script("run_all.py")
        if result.returncode == 0:
            st.success("Full pipeline completed")
            st.code(result.stdout)
        else:
            st.error("Full pipeline failed")
            st.code(result.stderr)
        
        
latest = get_latest_etl()

col1, col2, col3 = st.columns(3)

with col1:
    st.metric("Database", cfg["mysql"]["database"])

with col2:
    st.metric("ETL Script", ETL_SCRIPT)

with col3:
    if latest:
        st.metric("Status", latest["status"])
    else:
        st.metric("Status", "No Data")

st.divider()

k1, k2, k3 = st.columns(3)

if latest:
    k1.metric("Inserted", latest["records_inserted"])
    k2.metric("Updated", latest["records_updated"])
    k3.metric("Duration(sec)", latest["duration_sec"])

st.subheader("Latest Log")

log_files = sorted(LOG_DIR.glob("*.log"), reverse=True)

if log_files:
    latest_log = log_files[0]
    st.caption(str(latest_log))

    log_text = latest_log.read_text(encoding="utf-8", errors="ignore")
    st.code(log_text[-5000:])
else:
    st.warning("No log files found.")
    
st.subheader("ETL History")

conn = mysql.connector.connect(
    host=cfg["mysql"]["host"],
    port=cfg["mysql"]["port"],
    user=cfg["mysql"]["user"],
    password=cfg["mysql"]["password"],
    database=cfg["mysql"]["database"]
)

query = """
SELECT
    started_at,
    ended_at,
    status,
    records_inserted,
    records_updated,
    TIMESTAMPDIFF(SECOND, started_at, ended_at) AS duration_sec,
    error_message
FROM etl_run_log
ORDER BY started_at DESC
LIMIT 20
"""

# =====================
# Recent Errors
# =====================

st.subheader("Recent Errors")

error_query = """
SELECT
    started_at,
    error_message
FROM etl_run_log
WHERE status = 'failed'
ORDER BY started_at DESC
LIMIT 20
"""

error_df = pd.read_sql(error_query, conn)

if len(error_df) == 0:
    st.success("No failed ETL runs found")
else:
    st.dataframe(error_df, use_container_width=True)
    
st.subheader("Duration Trend")

duration_query = """
SELECT
    DATE(started_at) AS run_date,
    AVG(TIMESTAMPDIFF(SECOND, started_at, ended_at)) AS duration_sec
FROM etl_run_log
GROUP BY DATE(started_at)
ORDER BY run_date
"""

duration_df = pd.read_sql(duration_query, conn)

st.line_chart(
    duration_df,
    x="run_date",
    y="duration_sec",
    use_container_width=True
)


st.subheader("Inserted Records Trend")

trend_query = """
SELECT
    DATE(started_at) AS run_date,
    SUM(records_inserted) AS inserted
FROM etl_run_log
GROUP BY DATE(started_at)
ORDER BY run_date
"""

trend_df = pd.read_sql(trend_query, conn)

st.bar_chart(
    trend_df,
    x="run_date",
    y="inserted",
    use_container_width=True
)

df = pd.read_sql(query, conn)

st.dataframe(df, use_container_width=True)

conn.close()