  -- Author: Paul Brown
  -- View Name balanced_quality_data [1.1]
  -- Date Last Update: 31st January, 2025
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the %age of items delivered in each week which are bugs by each team
  -- Project:
  -- Value Flow
WITH
  _throughput_data AS (
  SELECT
    PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) AS finished_date,
    COUNT(*) AS finished,
    team
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    NOT done IS NULL
    AND resolution IN ('Done',
      'Fixed',
      'In Production')  -- Exclude work that isn't adding value i.e. cancelled etc.
  GROUP BY
    1,
    3 ),
  _failure_demand AS (
  SELECT
    PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) AS finished_date,
    COUNT(*) AS failure_demand,
    team
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    NOT done IS NULL
    AND resolution IN ('Done',
      'Fixed',
      'In Production')  -- Exclude work that isn't adding value i.e. cancelled etc.
    AND demand_type = 'Failure'
  GROUP BY
    1,
    3 ),
  _combined AS (
    -- Merge throughput and failure demand data with dim-dates for week alignment
  SELECT
    dt.week_end_date,
    dt.week_of_year,
    dt.year_number,
    COALESCE(td.finished, 0) AS finished_count,
    0 AS failure_count,
    td.team
  FROM
    _throughput_data td
  LEFT JOIN
    `ctreportbuilder.abc.dim-dates` dt
  ON
    td.finished_date = dt.DATE_DAY
  UNION ALL
  SELECT
    dt.week_end_date,
    dt.week_of_year,
    dt.year_number,
    0 AS finished,
    COALESCE(fd.failure_demand, 0) AS failure_count,
    fd.team
  FROM
    _failure_demand fd
  LEFT JOIN
    `ctreportbuilder.abc_ea.dim-dates` dt
  ON
    fd.finished_date = dt.DATE_DAY ),
  _aggregated AS (
    -- Compute weekly totals per team
  SELECT
    week_end_date,
    week_of_year,
    year_number,
    SUM(failure_count) AS failure_demand,
    SUM(finished_count) AS total_demand,
    team
  FROM
    _combined
  WHERE
    NOT team IS NULL
  GROUP BY
    1,
    2,
    3,
    6 )
  -- Final query: Calculate defect rate and 4-week rolling average
SELECT
  week_end_date,
  week_of_year,
  year_number,
  team,
  failure_demand,
  total_demand,
  SAFE_DIVIDE(failure_demand, total_demand) AS defect_rate,
  -- Weekly defect rate
  AVG(SAFE_DIVIDE(failure_demand, total_demand)) OVER (PARTITION BY team ORDER BY week_end_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW ) AS rolling_4_week_avg  -- 4-week rolling average
FROM
  _aggregated
ORDER BY
  week_end_date;