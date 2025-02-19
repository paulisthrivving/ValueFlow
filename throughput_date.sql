  -- Author: Paul Brown
  -- View Name: throughput_date[v1.2]
  -- Date Last Update: 22nd January, 2025
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the throughput or departure rate (items completed in a defined period - in this case, per day) and the arrival rate for the system by date
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
    team,
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
    date_day)
SELECT
  date_day,
  throughput,
  arrival_rate,
  team
FROM
  _stats
WHERE
  team NOT IN ('Integration Services',
    'Data Solutions')
UNION ALL
SELECT
  date_day,
  throughput,
  arrival_rate,
  'Integration Services' AS team
FROM
  _stats
WHERE
  team = 'ERP'
UNION ALL
SELECT
  date_day,
  throughput,
  arrival_rate,
  'Data Solutions Joey' AS team
FROM
  _stats
WHERE
  team = 'Data Solutions'
UNION ALL
SELECT
  date_day,
  throughput,
  arrival_rate,
  'Data Solutions Cassey' AS team
FROM
  _stats
WHERE
  team = 'Data Solutions'
ORDER BY
  1,
  4