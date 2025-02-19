  -- Author: Paul Brown
  -- View Name: balanced_demand_data [1.1]
  -- Date Last Update: 14th February, 2025
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the throughput or departure rate (items completed in a defined period - in this case, per day) and the arrival rate for the system by date and by team name
  -- Project:
  -- ValueFlow
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
  GROUP BY
    1,
    3 ),
  _arrival_data AS (
  SELECT
    PARSE_DATE('%Y-%m-%d', CAST(started AS STRING)) AS starting_date,
    COUNT(started) AS started,
    team
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    NOT started IS NULL
  GROUP BY
    1,
    3 ),
  _combined AS (
    -- Align finished and started work with weekly dates
  SELECT
    dt.date_day,
    week_end_date,
    week_of_year,
    year_number,
    COALESCE(td.finished, 0) AS finished,
    0 AS started,
    td.team
  FROM
    _throughput_data td
  LEFT OUTER JOIN
    `ctreportbuilder.abc_ea.dim-dates` dt
  ON
    td.finished_date = dt.DATE_DAY
  UNION ALL
  SELECT
    dt.date_day,
    week_end_date,
    week_of_year,
    year_number,
    0 AS finished,
    COALESCE(ad.started, 0) AS started,
    ad.team
  FROM
    _arrival_data ad
  LEFT OUTER JOIN
    `ctreportbuilder.abc_ea.dim-dates` dt
  ON
    ad.starting_date = dt.DATE_DAY ),
  _aggregated AS (
    -- Aggregate throughput and arrival rate by week
  SELECT
    week_end_date,
    week_of_year,
    year_number,
    SUM(finished) AS throughput,
    SUM(started) AS arrival_rate,
    team
  FROM
    _combined
  WHERE
    NOT team IS NULL
    AND NOT week_end_date IS NULL
  GROUP BY
    1,
    2,
    3,
    6 )
  -- Final query with 4-week rolling average
SELECT
  week_end_date,
  week_of_year,
  year_number,
  throughput,
  arrival_rate,
  team,
  -- Compute 4-week rolling average for throughput
  AVG(throughput) OVER (PARTITION BY team ORDER BY week_end_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW ) AS rolling_4_week_avg
FROM
  _aggregated
ORDER BY
  week_end_date;