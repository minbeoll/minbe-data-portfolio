# Architecture

[World Bank API] ---> [Python ETL] ---> [MySQL] ---> [Power Query] ---> [Power BI]
                                  \--> [etl_run_log + daily_snapshot] ---> [Monitoring Page]
(Optional) [Crawling] ------------/
(Optional) [PDF/Email] <----------/
