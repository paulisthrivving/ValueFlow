  -- Author: Paul Brown
  -- View Name wia_that_madeit [1.0]
  -- Date Last Update: 5th October, 2024
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the percentage of items, regardless of type, which were older than the 70th percentile, but yet made it in under the 85th percentile for all of the data we have
  -- Project:
  -- ValueFlow
WITH
  _base_perc AS (
  SELECT
    DISTINCT team,
    PERCENTILE_CONT(cycle_time, 0.70) OVER(PARTITION BY team) AS cycle_time_70th_percentile,
    PERCENTILE_CONT(cycle_time, 0.85) OVER(PARTITION BY team) AS cycle_time_85th_percentile
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  LIMIT
    10),
  _made_it AS (
  SELECT
    ct.team,
    COUNT(ID) AS record_count,
    SUM(CASE
        WHEN cycle_time <= cycle_time_85th_percentile THEN 1
        ELSE 0
    END
      ) AS less_than_85th
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data` ct
  INNER JOIN
    _base_perc pe
  ON
    CT.team = pe.Team
  WHERE
    cycle_time >= cycle_time_70th_percentile
  GROUP BY
    1)
  -- what percentage of all of the record over the 70th percentile made it before hitting the SLE, by team
SELECT
  team,
  (less_than_85th / record_count) * 100 AS made_it
FROM
  _made_it