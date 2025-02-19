  -- Author: Paul Brown
  -- View Name: correlation_data [v1.1]
  -- Date Last Update: 17th September, 2024
  -- Parameters:
  --  None
  -- Query Description:
  --  Returns all of the data we have in the CT table where the work item is 'done'
  -- Project:
  --  ValueFlow
SELECT
  PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) AS date_day,
  id AS issue_key,
  issue_type,
  cycle_time,
  lead_time,
  team,
  COUNT(id) OVER (PARTITION BY cycle_time, issue_type, team) AS cycle_time_count
FROM
  `ctreportbuilder.abc_ea.abc-master-ct-data`
WHERE
  NOT done IS NULL
ORDER BY
  date_day;