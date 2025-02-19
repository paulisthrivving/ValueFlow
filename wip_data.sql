  -- Author: Paul Brown
  --View Name: wip_data [1.1]
  -- Date Last Update: October 13, 2024
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the running WIP (items started, but not finished) for the data by date - now includes opening position
  -- Project:
  --  ValueFlow
WITH
  date_range AS (
  SELECT
    MIN(date_day) AS min_date,
    MAX(date_day) AS max_date
  FROM
    `ctreportbuilder.abc_ea.dim-dates` ),
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
    CROSS JOIN
      date_range
    WHERE
      date_day BETWEEN date_range.min_date
      AND date_range.max_date
    ORDER BY
      1 )
  ORDER BY
    team,
    date_day ),
  _opening_wip AS (
  SELECT
    team,
    COUNT(*) AS opening_wip
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  CROSS JOIN
    date_range
  WHERE
    started < date_range.min_date
    AND (done IS NULL
      OR done > date_range.min_date)
    AND stage <> 'Removed'
  GROUP BY
    team ),
  _stats AS (
  SELECT
    _base.team,
    _base.date_day,
    COALESCE(_opening_wip.opening_wip, 0) AS opening_wip,
    (
    SELECT
      COUNT(*) AS done
    FROM
      `ctreportbuilder.abc_ea.abc-master-ct-data`
    WHERE
      NOT done IS NULL
      AND PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) = _base.date_day
      AND stage <> 'Removed'
      AND team = _base.team ) AS done,
    (
    SELECT
      COUNT(*) AS started
    FROM
      `ctreportbuilder.abc_ea.abc-master-ct-data`
    WHERE
      NOT started IS NULL
      AND PARSE_DATE('%Y-%m-%d', CAST(started AS STRING)) = _base.date_day
      AND stage <> 'Removed'
      AND team = _base.team ) AS started
  FROM
    _base
  LEFT JOIN
    _opening_wip
  ON
    _base.team = _opening_wip.team
  ORDER BY
    _base.team,
    _base.date_day ),
  _summary AS (
  SELECT
    date_day,
    started AS _in_progress,
    done AS finished,
    SUM(done) OVER (PARTITION BY team ORDER BY date_day ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS _running_finished,
    SUM(started) OVER (PARTITION BY team ORDER BY date_day ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS _running_started,
    opening_wip,
    team
  FROM
    _stats )
  -- Return running wip by date and team
SELECT
  date_day,
  _running_started + opening_wip AS total_started,
  _running_finished AS total_finished,
  (_running_started + opening_wip - _running_finished) AS total_wip,
  team
FROM
  _summary
ORDER BY
  team,
  date_day