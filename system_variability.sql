  -- Author: Paul Brown
  -- View Name: system_variability
  -- Date Last Update: 6th August, 2024 [v1.0]
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the throughput and analytical numbers by team
  -- Project:
  -- ValueFlow
WITH
  _throughput_data AS (
  SELECT
    PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) AS finished_date,
    COUNT(*) AS finished,
    MIN(cycle_time) AS min_ct,
    MAX(cycle_time) AS max_ct,
    SUM(cycle_time) AS total_ct,
    team
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    stage = 'Done'
  GROUP BY
    1,
    6
  ORDER BY
    1 ),
  _perc AS (
  SELECT
    PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) AS finished_date,
    PERCENTILE_CONT(Cycle_Time, 0.25) OVER (PARTITION BY done) AS perc_25,
    PERCENTILE_CONT(Cycle_Time, 0.5) OVER (PARTITION BY done) AS median,
    PERCENTILE_CONT(Cycle_Time, 0.75) OVER (PARTITION BY done) AS perc_75,
    team
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    NOT done IS NULL ),
  _combined AS (
    -- select all the dates from dim dates, and combine with the data we have
  SELECT
    dt.date_day,
    week_end_date,
    week_of_year,
    year_number,
    COALESCE(td.finished,0) AS finished,
    min_ct,
    max_ct,
    td.team,
    perc_25,
    median,
    perc_75,
    total_ct
  FROM
    `ctreportbuilder.abc_ea.dim-dates` dt
  LEFT OUTER JOIN
    _throughput_data td
  ON
    dt.DATE_DAY = td.finished_date
  LEFT OUTER JOIN
    _perc pc
  ON
    td.finished_date = pc.finished_date
    AND td.team = pc.team
  WHERE
    NOT date_day IS NULL
  ORDER BY
    date_day)
  -- Return daily throughput by date
SELECT
  week_end_date,
  week_of_year,
  year_number,
  SUM(finished) AS throughput,
  MIN(min_ct) AS min_ct,
  MIN(perc_25) AS perc_25,
  MIN(median) AS median,
  MIN(perc_75) AS perc_75,
  MAX(max_ct) AS max_ct,
  SUM(total_ct) AS total_ct,
  team
FROM
  _combined
WHERE
  NOT team IS NULL
GROUP BY
  1,
  2,
  3,
  11
ORDER BY
  week_end_date