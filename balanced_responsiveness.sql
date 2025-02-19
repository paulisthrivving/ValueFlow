  -- Author: Paul Brown
  -- View name: balanced_responsiveness
  -- Date Last Update: 3rd February, 2025 [v1.1]
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
    AVG(cycle_time) AS avg_ct,
    SUM(cycle_time) AS total_ct,
    team
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    NOT done IS NULL
  GROUP BY
    1,
    7 ),
  _perc AS (
  SELECT
    PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) AS finished_date,
    PERCENTILE_CONT(Cycle_Time, 0.25) OVER (PARTITION BY done, team) AS perc_25,
    PERCENTILE_CONT(Cycle_Time, 0.5) OVER (PARTITION BY done, team) AS median,
    PERCENTILE_CONT(Cycle_Time, 0.75) OVER (PARTITION BY done, team) AS perc_75,
    team
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    NOT done IS NULL ),
  _combined AS (
    -- Merge throughput, cycle time percentiles, and date alignment
  SELECT
    dt.date_day,
    week_end_date,
    week_of_year,
    year_number,
    COALESCE(td.finished, 0) AS finished,
    COALESCE(td.min_ct, 0) AS min_ct,
    COALESCE(td.max_ct, 0) AS max_ct,
    COALESCE(td.avg_ct, 0) AS avg_ct,
    COALESCE(td.total_ct, 0) AS total_ct,
    td.team,
    COALESCE(pc.perc_25, 0) AS perc_25,
    COALESCE(pc.median, 0) AS median,
    COALESCE(pc.perc_75, 0) AS perc_75
  FROM
    `ctreportbuilder.abc_ea.dim-dates` dt
  LEFT JOIN
    _throughput_data td
  ON
    dt.DATE_DAY = td.finished_date
  LEFT JOIN
    _perc pc
  ON
    td.finished_date = pc.finished_date
    AND td.team = pc.team
  WHERE
    NOT date_day IS NULL ),
  _aggregated AS (
    -- Compute weekly totals per team
  SELECT
    week_end_date,
    week_of_year,
    year_number,
    SUM(finished) AS throughput,
    MIN(min_ct) AS min_ct,
    MIN(perc_25) AS perc_25,
    MIN(median) AS median,
    MIN(avg_ct) AS average,
    MIN(perc_75) AS perc_75,
    MAX(max_ct) AS max_ct,
    SUM(total_ct) AS total_ct,
    team
  FROM
    _combined
  WHERE
    NOT team IS NULL
  GROUP BY
    week_end_date,
    week_of_year,
    year_number,
    team )
  -- Final query: Compute rolling average for throughput
SELECT
  week_end_date,
  week_of_year,
  year_number,
  throughput,
  team,
  min_ct,
  perc_25,
  median,
  average,
  perc_75,
  max_ct,
  total_ct,
  -- Compute 4-week rolling average
  AVG(average) OVER (PARTITION BY team ORDER BY week_end_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW ) AS rolling_4_week_avg
FROM
  _aggregated
ORDER BY
  week_end_date;