  -- Author: Paul Brown
  -- View Name: correlation_numbers
  -- Date Last Update: 18th February, 2025 [v1.0]
  -- Parameters:
  --  None
  -- Query Description:
  --  Return the cycle time and effort numbers by team, which are in the correlation number
  -- Project:
  --  ValueFlow
SELECT
  id,
  cycle_time,
  story_points,
  done AS done_date,
  team
FROM
  `ctreportbuilder.abc_ea.abc-master-ct-data`
WHERE
  stage = 'Done'
  AND cycle_time > 0
  AND story_points > 0
  AND NOT story_points IS NULL
  AND NOT team IS NULL
  AND PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) > '2023-09-01'
ORDER BY
  team,
  story_points