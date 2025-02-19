  -- Author: Paul Brown
  -- View Name: balanced_wia [1.0]
  -- Date Last Update: 5th November, 2024
  -- Parameters:
  --  None
  -- Query Description:
  --  Show the average work item age by week and by team
  -- Project:
  --  ValueFlow
WITH
  date_range AS (
  SELECT
    MIN(DATE_SUB(CAST(started AS DATE), INTERVAL EXTRACT(DAYOFWEEK
        FROM
          CAST(started AS DATE)) - 1 DAY)) AS min_date,
    MAX(DATE_SUB(CAST(started AS DATE), INTERVAL EXTRACT(DAYOFWEEK
        FROM
          CAST(started AS DATE)) - 1 DAY)) AS max_date
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data` ),
  week_dates AS (
  SELECT
    DATE_ADD(min_date, INTERVAL week_num WEEK) AS week_end_date
  FROM
    date_range,
    UNNEST(GENERATE_ARRAY(0, DATE_DIFF(max_date, min_date, WEEK))) AS week_num ),
  work_item_ages AS (
  SELECT
    team,
    DATE_TRUNC(DATE_SUB(CAST(started AS DATE), INTERVAL EXTRACT(DAYOFWEEK
        FROM
          CAST(started AS DATE)) - 1 DAY), WEEK) AS week_end_date,
    work_item_age
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    work_item_age IS NOT NULL )
SELECT
  week_dates.week_end_date,
  work_item_ages.team,
  AVG(work_item_ages.work_item_age) AS average_work_item_age
FROM
  week_dates
LEFT JOIN
  work_item_ages
ON
  week_dates.week_end_date = work_item_ages.week_end_date
GROUP BY
  week_dates.week_end_date,
  work_item_ages.team
ORDER BY
  week_dates.week_end_date DESC,
  work_item_ages.team;