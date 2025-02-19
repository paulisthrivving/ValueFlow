  -- Author: Paul Brown
  -- View Name: flow_debt_by_week[v1.1]
  -- Date Last Update: 24th January, 2025
  -- Parameters:
  --  None
  -- Query Description:
  --  Calculates and returns the flow debt for the system for all dates by week
  -- Project:
  --  ValueFlow
WITH
  _base AS (
  SELECT
    DISTINCT team,
    LAST_DAY(date_day, week) AS week_end_date
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  CROSS JOIN (
    SELECT
      date_day
    FROM
      `ctreportbuilder.abc_ea.dim-dates`
    ORDER BY
      date_day) ),
  wip_aggregates AS (
  SELECT
    team,
    LAST_DAY(date_day, week) AS week_end_date,
    AVG(total_wip) AS avg_total_wip
  FROM
    `ctreportbuilder.abc_ea.wip_data`
  GROUP BY
    team,
    week_end_date ),
  throughput_aggregates AS (
  SELECT
    team,
    LAST_DAY(date_day, week) AS week_end_date,
    AVG(throughput) AS avg_throughput
  FROM
    `ctreportbuilder.abc_ea.throughput_date`
  GROUP BY
    team,
    week_end_date ),
  ct_aggregates AS (
  SELECT
    team,
    LAST_DAY(PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)), week) AS week_end_date,
    AVG(cycle_time) AS avg_ct
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    Done IS NOT NULL
  GROUP BY
    team,
    week_end_date ),
  _summary AS (
  SELECT
    b.week_end_date,
    b.team,
    COALESCE(w.avg_total_wip, 0) AS avg_total_wip,
    COALESCE(t.avg_throughput, 0) AS avg_throughput,
    COALESCE(c.avg_ct, 0) AS avg_ct,
    CASE
      WHEN COALESCE(t.avg_throughput, 0) > 0 THEN COALESCE(w.avg_total_wip, 0) / COALESCE(t.avg_throughput, 0)
      ELSE 0
  END
    AS approx_avg_ct
  FROM
    _base b
  LEFT JOIN
    wip_aggregates w
  ON
    b.team = w.team
    AND b.week_end_date = w.week_end_date
  LEFT JOIN
    throughput_aggregates t
  ON
    b.team = t.team
    AND b.week_end_date = t.week_end_date
  LEFT JOIN
    ct_aggregates c
  ON
    b.team = c.team
    AND b.week_end_date = c.week_end_date )
SELECT
  *,
  CASE
    WHEN (approx_avg_ct - COALESCE(avg_ct, 0)) = 0 THEN 0
    ELSE (approx_avg_ct - COALESCE(avg_ct, 0)) * -1
END
  AS flow_debt
FROM
  _summary
ORDER BY
  week_end_date,
  team;