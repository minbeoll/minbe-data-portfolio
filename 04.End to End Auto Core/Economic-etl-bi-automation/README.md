# Global Economic Monitoring & Automated Reporting System

End-to-end BI automation project integrating:
- REST API (World Bank)
- MySQL (star-schema friendly tables)
- Power BI (monitoring + analysis)
- Daily snapshot + ETL run logging
- (Optional) crawling + PDF/email automation

## Quick Start
1) Configure: config/config.yaml
2) Run ETL:
   - python 3_etl\wb_fetcher.py
   - or python 3_etl\run_all.py
3) Verify DB:
   - SELECT COUNT(*) FROM fact_observation;
4) Refresh Power BI report and check the Monitoring page.
