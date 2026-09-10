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
