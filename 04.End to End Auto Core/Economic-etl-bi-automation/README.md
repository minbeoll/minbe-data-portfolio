Videolink - https://youtu.be/9SMHp9CUOfM


# Global Economic Monitoring & BI Automation System

An end-to-end data automation and Business Intelligence project that
collects global economic data from the World Bank API, processes it through
a Python ETL pipeline, stores it in MySQL, monitors pipeline execution through
a Streamlit control panel, and visualizes the results in Power BI.

---

## Architecture

World Bank REST API
        ↓
Python ETL Pipeline
        ↓
MySQL Database
        ↓
Streamlit Control & Monitoring
        ↓
Power BI Dashboard

---

## Tech Stack

- Python
- MySQL
- REST API
- Power Query
- Power BI
- DAX
- Streamlit
- Git / GitHub

---

## Key Features

### Data Collection & ETL
- Collect economic indicators from the World Bank REST API
- Transform and validate API data with Python
- Insert and update observations in MySQL
- Retry handling for temporary API failures
- Daily snapshot generation

### ETL Monitoring
- ETL execution logging
- Inserted / Updated record tracking
- Execution duration tracking
- Error logging and ETL history

### Streamlit Control Panel
- Run API pipeline
- Run snapshot
- Run complete ETL pipeline
- Open configuration and log folders
- Open Power BI dashboard
- Refresh dashboard
- Display Power BI refresh timestamp

### Power BI Analytics
- Global economic monitoring dashboard
- Country comparison
- Historical trend analysis
- Country ranking
- KPI measures
- Normalized Index analysis
- DAX-based analytical measures

---

## Project Structure

Economic-etl-bi-automation/

    0.Docs/
    1.Data_Raw/
    2.Database/
    3.ETL/
    4.PowerQuery/
    5.PowerBI/
    6.Reporting/
    7.Scheduler/
    config/
    Control Panel/
    logs/
    README.md
    requirements.txt

---

## Configuration

Copy:

    config/config.example.yaml

and create:

    config/config.yaml

Then configure your local MySQL connection.

Never commit passwords or other credentials to GitHub.

---

## Quick Start

1. Install dependencies

    pip install -r requirements.txt

2. Configure MySQL

    config/config.yaml

3. Run the ETL pipeline

    python 3.ETL/run_all.py

4. Verify the database

    SELECT COUNT(*) FROM fact_observation;

5. Launch the Streamlit Control Panel

    streamlit run apps/Control/app.py

6. Refresh and open the Power BI dashboard.

---

## ETL Workflow

API Request
    ↓
Data Validation
    ↓
Transformation
    ↓
MySQL Insert / Update
    ↓
Snapshot
    ↓
ETL Logging
    ↓
Power BI Refresh

---

## Dashboard

The Power BI report provides two main analytical views:

### Global Economic Monitoring
- Country and indicator KPIs
- Global map
- Economic indicator trends
- Country comparison
- Normalized Index

### Country Analysis
- Country ranking
- Historical trends
- Latest economic values
- Rank position
- Indicator coverage

---

## Project Goal

The goal of this project is to demonstrate how multiple data technologies
can be integrated into a reusable end-to-end BI automation workflow.

Rather than building only a dashboard, the project covers the complete
data lifecycle:

Data Collection → ETL → Database → Monitoring → Analytics → Reporting

---

## Author

Minbe Data Portfolio