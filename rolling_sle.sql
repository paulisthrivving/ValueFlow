  -- Author: Paul Brown
  -- View Name: folling_sle
  -- Date Last Update: 6th November, 2024 [v1.0]
  -- Parameters:
  --  None
  -- Query Description:
  --  Give me a weekly rolling view of a team SLE
  -- Project:
  -- ValueFlow
WITH
  base_data AS (
  SELECT
    team,
    DATE_TRUNC(PARSE_DATE('%Y-%m-%d', CAST(done AS STRING)), WEEK(MONDAY)) + INTERVAL 6 DAY AS week_end_date,
    cycle_time
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    done IS NOT NULL
    AND cycle_time > 0 ),
  -- Create all combinations of team and week_end_date
  weeks_teams AS (
  SELECT
    DISTINCT team,
    week_end_date
  FROM
    base_data ),
  -- Cross join with base_data to get all historical data for each week
  expanded_data AS (
  SELECT
    wt.team,
    wt.week_end_date,
    bd.cycle_time
  FROM
    weeks_teams wt
  LEFT JOIN
    base_data bd
  ON
    bd.team = wt.team
    AND bd.week_end_date <= wt.week_end_date ),
  -- Calculate the 85th percentile for each team and week combination
  final_sle AS (
  SELECT
    team,
    week_end_date,
    PERCENTILE_CONT(cycle_time, 0.85) OVER (PARTITION BY team, week_end_date ) AS sle_85th_percentile
  FROM
    expanded_data
  WHERE
    cycle_time IS NOT NULL )
  -- Final output with distinct results and ordering
SELECT
  DISTINCT team,
  week_end_date,
  ROUND(sle_85th_percentile,0) AS current_sle
FROM
  final_sle
ORDER BY
  team,
  week_end_date;