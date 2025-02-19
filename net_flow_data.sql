  -- Author: Paul Brown
  -- View Name: net_flow_data[v1.1]
  -- Date Last Update: 14th February, 2025
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the throughput or departure rate (items completed in a defined period - in this case, per day) and the arrival rate for the system by date and by team name
  -- Project:
  -- ValueFlow
WITH
  _base AS (
  SELECT
    DISTINCT team,
    date_day
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  CROSS JOIN (
    SELECT
      date_day
    FROM
      `ctreportbuilder.abc_ea.dim-dates` dates
    ORDER BY
      1)
  ORDER BY
    date_day),
  _stats AS (
  SELECT
    team,
    date_day,
    (
    SELECT
      COUNT(*) AS done
    FROM
      `ctreportbuilder.abc_ea.abc-master-ct-data`
    WHERE
      NOT done IS NULL
      AND PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) = _base.date_day
      AND stage <> 'Rejected'
      AND team = _base.team) AS throughput,
    (
    SELECT
      COUNT(*) AS started
    FROM
      `ctreportbuilder.abc_ea.abc-master-ct-data`
    WHERE
      NOT started IS NULL
      AND PARSE_DATE('%Y-%m-%d', CAST(started AS STRING)) = _base.date_day
      AND stage <> 'Rejected'
      AND team = _base.team) AS arrival_rate
  FROM
    _base
  ORDER BY
    date_day),
  aggregated AS (
  SELECT
    LAST_DAY(date_day, week) AS week_end_date,
    SUM(throughput) AS finished,
    SUM(arrival_rate) AS started,
    SUM(throughput) - SUM(arrival_rate) AS net_flow,
    team
  FROM
    _stats
  GROUP BY
    1,
    5 )
SELECT
  week_end_date,
  finished,
  started,
  net_flow,
  team,
  -- Compute 4-week rolling average for Net Flow
  AVG(net_flow) OVER (PARTITION BY team ORDER BY week_end_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW ) AS rolling_4_week_avg
FROM
  aggregated
ORDER BY
  week_end_date;