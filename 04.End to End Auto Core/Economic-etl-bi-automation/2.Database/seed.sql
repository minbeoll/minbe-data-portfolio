USE economic_monitoring_db;

INSERT INTO dim_country (country_code, country_name)
VALUES
  ('USA', 'United States'),
  ('KOR', 'South Korea'),
  ('JPN', 'Japan'),
  ('DEU', 'Germany'),
  ('FRA', 'France')
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

INSERT INTO dim_country (country_code, country_name)
VALUES
  ('FRA', 'France')
ON DUPLICATE KEY UPDATE
  country_name = VALUES(country_name);
