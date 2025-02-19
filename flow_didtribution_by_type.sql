  -- Author: Paul Brown
  --View Name: flow_didtribution_by_type [1.0]
  -- Date Last Update: 17th September, 2024
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the running WIP (items started, but not finished) for the data by date - now filters removed
  -- Project:
  -- ValueFlow
WITH
  _base AS (
  SELECT
    DISTINCT team,
    date_day,
    issue_type AS work_item_type,
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  CROSS JOIN (
    SELECT
      date_day
    FROM
      `ctreportbuilder.abc_ea.dim-dates` dates
    WHERE
      date_day <= CURRENT_DATE
    ORDER BY
      1)
  ORDER BY
    date_day),
  _stats AS (
  SELECT
    team,
    date_day,
    work_item_type,
    (
    SELECT
      COUNT(*) AS done
    FROM
      `ctreportbuilder.abc_ea.abc-master-ct-data`
    WHERE
      NOT done IS NULL
      AND PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) = _base.date_day
      AND stage <> 'Rejected'
      AND team = _base.team
      AND work_item_type = _base.work_item_type) AS done,
    (
    SELECT
      COUNT(*) AS started
    FROM
      `ctreportbuilder.abc_ea.abc-master-ct-data`
    WHERE
      NOT started IS NULL
      AND PARSE_DATE('%Y-%m-%d', CAST(started AS STRING)) = _base.date_day
      AND stage <> 'Rejected'
      AND team = _base.team
      AND work_item_type = _base.work_item_type) AS started
  FROM
    _base
  ORDER BY
    date_day)
SELECT
  date_day,
  team,
  work_item_type,
  CASE
    WHEN ( (SUM(started) OVER (PARTITION BY team, work_item_type ORDER BY date_day, team, work_item_type ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))- (SUM(done) OVER (PARTITION BY team, work_item_type ORDER BY date_day, team, work_item_type ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))) < 0 THEN 0
    ELSE (SUM(started) OVER (PARTITION BY team, work_item_type ORDER BY date_day, team, work_item_type ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))- (SUM(done) OVER (PARTITION BY team, work_item_type ORDER BY date_day, team, work_item_type ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
END
  AS running_count,
FROM
  _stats
ORDER BY
  date_day,
  team,
  work_item_type