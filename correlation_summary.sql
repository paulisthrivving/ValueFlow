  -- Author: Paul Brown
  -- View Name: correlation_summary [v1.0]
  -- Date Last Update: 18th February, 2025
  -- Parameters:
  --  None
  -- Query Description:
  --  Return the correlation numbers by team between story points and by cycle time
  -- Project:
  --  ValueFlow
SELECT
  DISTINCT CORR(story_points, cycle_time) OVER (PARTITION BY team) AS correlation,
  team
FROM
  `ctreportbuilder.abc_ea.abc-master-ct-data`
WHERE
  stage = 'Done'
  AND cycle_time > 0
  AND story_points > 0
  AND NOT story_points IS NULL
  AND NOT team IS NULL
  AND PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) > '2023-09-01';